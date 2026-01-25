import CasePaths
import ConcurrencyExtras
import Dependencies
import Foundation
import Logging

// import Observation
// import Perception

let logger = {
  LoggingSystem.bootstrap { label in
    var output = StreamLogHandler.standardOutput(label: label)
    #if DEBUG
      output.logLevel = .trace
    #else
      output.logLevel = .critical
    #endif
    return output
  }
  return Logger(label: "dev.erikb.tiny-composable-architecture")
}()

public final class Store<State, Action>: _Store, @unchecked Sendable {
  private weak var parent: (any _Store)?
  private var currentState: State
  private var bufferedActions: [Action] = []
  private var isSending = false
  private let reducer: any Reducer<State, Action>
  private let logger: Logger
  private var effectCancellables: [UUID: () -> Void] = [:]
  private var children: [ScopeID<State, Action>: AnyObject] = [:]
  private var scopeID: AnyHashable?

  public init<R: Reducer<State, Action>>(
    initialState: @autoclosure () -> R.State,
    @ReducerBuilder<State, Action> reducer: () -> R,
    withDependencies prepareDependencies: ((inout DependencyValues) -> Void)? = nil
  ) {
    let (initialState, reducer, dependencies) = withDependencies(prepareDependencies ?? { _ in }) {
      @Dependency(\.self) var dependencies
      return (initialState(), reducer(), dependencies)
    }
    self.currentState = initialState
    self.parent = nil
    self.reducer = reducer.dependency(\.self, dependencies)
    var logger = Logger(label: "Store<\(State.self), \(Action.self)>")
    logger[metadataKey: "id"] = "\(UUID().uuidString)"
    self.logger = logger
  }

  deinit {
    logger.debug("deinit")
    for effect in effectCancellables {
      effect.value()
    }
    self.effectCancellables.removeAll()
  }

  public func withState<Value>(_ keyPath: KeyPath<State, Value>) -> Value {
    self.currentState[keyPath: keyPath]
  }

  @discardableResult
  public func send(_ action: Action) -> StoreTask {
    self.bufferedActions.append(action)
    guard !isSending else { return StoreTask(rawValue: nil) }

    self.isSending = true
    var currentState = self.currentState
    let tasks = LockIsolated([Task<Void, Never>]())

    defer {
      withExtendedLifetime(self.bufferedActions) {
        self.logger.debug("Removing all buffered actions.")
        self.bufferedActions.removeAll()
      }
      self.currentState = currentState
      self.isSending = false
      if !self.bufferedActions.isEmpty, let task = self.send(self.bufferedActions.removeLast()).rawValue {
        tasks.withValue { $0.append(task) }
      }
    }

    var index = self.bufferedActions.startIndex

    while index < self.bufferedActions.endIndex {
      defer { index += 1 }
      let action = self.bufferedActions[index]
      let effect = reducer.reduce(into: &currentState, action: action)

      let uuid = UUID()

      switch effect.operation {
      case .none:
        break
      case .action(let unchecked):
        let uncheckedAction = unchecked.wrappedValue
        withEscapedDependencies { continuation in
          if let task = continuation.yield({ self.send(uncheckedAction) }).rawValue {
            tasks.withValue { $0.append(task) }
          }
        }
      case let .task(name, priority, operation):
        let typeOfAction = type(of: action)
        withEscapedDependencies { continuation in
          let task = Task(name: name, priority: priority) { [weak self, logger, typeOfAction] in
            let isCompleted = LockIsolated(false)
            defer { isCompleted.setValue(true) }
            await operation(
              Send { [weak self] effectAction in
                if isCompleted.value {
                  logger.debug(
                    """
                    An action was sent from a completed effect.

                      Action:
                        \(type(of: effectAction))

                      Effect returned from:
                        \(typeOfAction)

                    Avoid sending actions using the 'send' argument from 'Effect.run' after \
                    the effect has completed. This can happen if you escape the 'send' \
                    argument in an unstructured context.

                    To fix this, make sure that your 'run' closure does not return until \
                    you're done calling 'send'.
                    """
                  )
                }
                let storeTask = continuation.yield({ self?.send(effectAction) })
                if let task = storeTask?.rawValue {
                  tasks.withValue { $0.append(task) }
                }
                return SendTask(base: storeTask ?? StoreTask(rawValue: nil))
              }
            )
            self?.effectCancellables[uuid] = nil
          }

          tasks.withValue { $0.append(task) }
          self.effectCancellables[uuid] = task.cancel
        }
      }
    }

    guard !tasks.isEmpty else { return StoreTask(rawValue: nil) }

    return StoreTask(
      rawValue: Task {
        await withTaskCancellationHandler {
          var index = tasks.startIndex
          while index < tasks.endIndex {
            defer { index += 1 }
            await tasks[index].value
          }
        } onCancel: {
          var index = tasks.startIndex
          while index < tasks.endIndex {
            defer { index += 1 }
            tasks[index].cancel()
          }
        }
      }
    )
  }

  // public func scope<ChildState, ChildAction, R>(
  //   state: KeyPath<State, ChildState>,
  //   action: CaseKeyPath<Action, ChildAction>,
  //   @ReducerBuilder<ChildState, ChildAction> childReducer: () -> R
  // ) -> Store<ChildState, ChildAction> {
  //   // let child = Store<ChildState, ChildAction>()
  // }

  func removeChild(_ id: AnyHashable) {
    self.children[id.base as! ScopeID<State, Action>] = nil
  }
}

public struct StoreTask: Hashable, Sendable {
  let rawValue: Task<Void, Never>?

  public func cancel() {
    self.rawValue?.cancel()
  }

  public func finish() async {
    await self.rawValue?.cancellableValue
  }

  public var isCancelled: Bool {
    self.rawValue?.isCancelled ?? true
  }
}

// extension Store: Observable {}

public typealias StoreOf<R: Reducer> = Store<R.State, R.Action>

protocol _Store: AnyObject {
  func removeChild(_ id: AnyHashable)
}

struct ScopeID<State, Action>: Hashable {
  let state: PartialKeyPath<State>
  let action: PartialCaseKeyPath<Action>
}
