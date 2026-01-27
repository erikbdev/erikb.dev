import ConcurrencyExtras
import Dependencies

public struct Effect<State, Action>: Sendable {
  enum Operation: Sendable {
    case none
    // Immediately executes action.
    case action(@autoclosure @Sendable () -> Action)
    case task(
      name: String? = nil,
      priority: TaskPriority? = nil,
      operation: @Sendable (_ send: Send<Action>) async -> Void
    )
  }

  let operation: Operation
}

public typealias EffectOf<R: Reducer> = Effect<R.State, R.Action>

extension Effect {
  public static var none: Self {
    Self(operation: .none)
  }

  @_disfavoredOverload
  public static func run(
    name: String? = nil,
    priority: TaskPriority? = nil,
    operation: @Sendable @escaping (_ send: Send<Action>) async throws -> Void,
    catch handler: (@Sendable (_ error: any Error, _ send: Send<Action>) async -> Void)? = nil
  ) -> Self {
    withEscapedDependencies { continuation in
      Self(
        operation: .task(name: name, priority: priority) { send in
          await continuation.yield {
            do {
              try await operation(send)
            } catch is CancellationError {
              return
            } catch {
              guard !Task.isCancelled else { return }
              await handler?(error, send)
            }
          }
        }
      )
    }
  }

  public static func send(_ action: @escaping @Sendable () -> Action) -> Self {
    return Self(operation: .action(action()))
  }
}

public struct Send<Action>: Sendable {
  let send: @StoreActor @Sendable (Action)-> SendTask

  // Should this return a store task wrapped inside a send task?
  @discardableResult
  @StoreActor
  public func callAsFunction(_ action: Action) -> SendTask {
    guard !Task.isCancelled else { return SendTask(base: StoreTask(rawValue: nil)) }
    return self.send(action)
  }
}

public struct SendTask: Sendable {
  let base: StoreTask

  public func finish() async {
    await base.finish()
  }

  public var isCancelled: Bool { base.isCancelled }
}
