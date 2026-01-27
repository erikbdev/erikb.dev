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

@dynamicMemberLookup
public actor Store<State, Action>: @preconcurrency _Store, Sendable {
  private weak var parent: (any _Store)?
  private var currentState: State
  private let reducer: any Reducer<State, Action>
  private let logger: Logger
  private var effectCancellables: [UUID: AnyCancellable] = [:]
  private var children: [ScopeID<State, Action>: AnyObject] = [:]
  private var scopeID: AnyHashable?

  func effectCount() -> Int {
    effectCancellables.count
  }

  public var state: State { currentState }

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
  }

  public func modify<R>(_ operation: (inout State) -> R) -> R {
    var currentState = currentState
    defer { self.currentState = currentState }
    return operation(&currentState)
  }

  @discardableResult
  public func send(_ action: Action) -> StoreTask {
    var currentState = self.currentState
    defer { self.currentState = currentState }

    let effect = self.reducer.reduce(into: &currentState, action: action)
    let effectId = UUID()

    switch effect.operation {
    case .none:
      return StoreTask(rawValue: nil)
    case .action(let effectAction):
      return withEscapedDependencies { continuation in 
        continuation.yield {
          self.send(effectAction())
        }
      }
    case let .task(name, priority, operation):
      let task = withEscapedDependencies { [weak self] continuation in
        Task(name: name, priority: priority) { [weak self] in
          let isCompleted = LockIsolated(false)
          defer { isCompleted.setValue(true) }
          guard let self else { return }
          // TODO: create a EffectStore that restricts user's
          // edits if isCompleted is false.
          //
          //     if isCompleted.value {
          //       logger.debug(
          //         """
          //         An action was sent from a completed effect.

          //           Action:
          //             \(type(of: effectAction))

          //           Effect returned from:
          //             \(typeOfAction)

          //         Avoid sending actions using the 'send' argument from 'Effect.run' after \
          //         the effect has completed. This can happen if you escape the 'send' \
          //         argument in an unstructured context.

          //         To fix this, make sure that your 'run' closure does not return until \
          //         you're done calling 'send'.
          //         """
          //       )

          await operation(self)
          await self.removeEffect(effectId)
        }
      }
      effectCancellables[effectId] = AnyCancellable(task.cancel)
      return StoreTask(rawValue: task)
    }
  }

  public subscript<Value>(dynamicMember keyPath: _SendableKeyPath<State, Value>) -> Value {
    self.currentState[keyPath: keyPath]
  }

  private func removeEffect(_ id: UUID) {
    self.effectCancellables[id] = nil
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
