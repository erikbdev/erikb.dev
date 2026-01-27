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
      operation: @Sendable (_ store: isolated Store<State, Action>) async -> Void
    )
  }

  let operation: Operation
}

public typealias EffectOf<R: Reducer> = Effect<R.State, R.Action>

extension Effect {
  public static var none: Self {
    Self(operation: .none)
  }

  public static func run(
    name: String? = nil,
    priority: TaskPriority? = nil,
    operation: @Sendable @escaping (_ store: isolated Store<State, Action>) async throws -> Void,
    catch handler: (@Sendable (_ error: any Error, _ store: isolated Store<State, Action>) async -> Void)? = nil
  ) -> Self {
    withEscapedDependencies { continuation in
      Self(
        operation: .task(name: name, priority: priority) { store in
          await continuation.yield { [store] in
            do {
              try await operation(store)
            } catch is CancellationError {
              return
            } catch {
              guard !Task.isCancelled else { return }
              await handler?(error, store)
            }
          }
        }
      )
    }
  }

  public static func send(_ action: @escaping @Sendable () -> Action) -> Self {
    Self(operation: .action(action()))
  }
}
