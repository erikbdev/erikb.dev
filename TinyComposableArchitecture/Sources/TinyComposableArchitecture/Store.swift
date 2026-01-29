import CasePaths
import ConcurrencyExtras
import Dependencies
import Foundation
import Logging

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
public actor Store<State, Action>: Sendable, Identifiable {
  private let logger: Logger
  public private(set) var state: State
  private let reducer: any Reducer<State, Action>
  private var effectCancellables: [UUID: AnyCancellable] = [:]

  var effectCancellablesCount: Int { effectCancellables.count }

  public let id = UUID()

  public init<R: Reducer<State, Action>>(
    initialState: @autoclosure () -> R.State,
    @ReducerBuilder<State, Action> reducer: () -> R,
    withDependencies prepareDependencies: ((inout DependencyValues) -> Void)? = nil
  ) {
    let (initialState, reducer, dependencies) = withDependencies(prepareDependencies ?? { _ in }) {
      @Dependency(\.self) var dependencies
      return (initialState(), reducer(), dependencies)
    }
    self.state = initialState
    self.reducer = reducer.dependency(\.self, dependencies)
    var logger = Logger(label: "Store<\(State.self), \(Action.self)>")
    logger[metadataKey: "id"] = "\(self.id.uuidString)"
    self.logger = logger
  }

  init() {
    // no-op
    fatalError("Implement no-op/invalid store")
  }

  // init<ParentState, ParentAction>(
  //   parentToChildState: KeyPath<ParentState, State>,
  //   parentToChildAction: CaseKeyPath<ParentAction, Action>
  // ) {
  //   fatalError()
  // }

  deinit {
    logger.debug("deinit")
  }

  public func modify<R>(_ operation: (inout State) -> R) -> R {
    var currentState = state
    defer { state = currentState }
    return operation(&currentState)
  }

  public subscript<Value>(dynamicMember keyPath: _SendableWritableKeyPath<State, Value>) -> Value {
    get {
      // TODO: register access recursively
      return self.state[keyPath: keyPath]
    }
    set {
      // TODO: register mutation
      self.state[keyPath: keyPath] = newValue
    }
    _modify {
      // TODO: register modify
      yield &self.state[keyPath: keyPath]
    }
  }

  @discardableResult
  public func send(_ action: Action) -> StoreTask {
    var currentState = self.state
    defer { self.state = currentState }

    let effect = self.reducer.reduce(into: &currentState, action: action)
    let effectId = UUID()

    switch effect.operation {
    case .none:
      return StoreTask(rawValue: nil)
    case let .run(name, priority, operation):
      let task = withDependencies({ _ in }) { [weak self] in
        Task(name: name, priority: priority) { [weak self] in
          await operation(self ?? Store())
          await self?.removeEffect(id: effectId)
        }
      }
      self.effectCancellables[effectId] = AnyCancellable(task.cancel)
      return StoreTask(rawValue: task)
    }
  }

  private func removeEffect(id: UUID) {
    self.effectCancellables[id] = nil
  }

  // public nonisolated func scope<ChildState, ChildAction>(
  //   state childStateKeyPath: KeyPath<State, ChildState>,
  //   action childActionCaseKeyPath: CaseKeyPath<Action, ChildAction>
  // ) -> Store<ChildState, ChildAction> {
  //   // let child = Store<ChildState, ChildAction>(
  //   //   parentToChildState: childStateKeyPath,
  //   //   parentToChildAction: childActionCaseKeyPath
  //   // )
  //   fatalError("Not implemented")
  // }
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

public typealias StoreOf<R: Reducer> = Store<R.State, R.Action>

struct ScopeID<State, Action>: Hashable {
  let state: PartialKeyPath<State>
  let action: PartialCaseKeyPath<Action>
}
