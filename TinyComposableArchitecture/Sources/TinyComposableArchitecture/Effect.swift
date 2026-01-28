import ConcurrencyExtras
import Dependencies

public struct Effect<State, Action>: Sendable {
  enum Operation: Sendable {
    case none
    case run(
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
    catch handler: (@Sendable (_ error: any Error, _ store: isolated Store<State, Action>) async -> Void)? = nil,
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column
  ) -> Self {
    withEscapedDependencies { escaped in
      Self(
        operation: .run(name: name, priority: priority) { store in
          await escaped.yield { [weak store] in
            do {
              try await operation(store ?? Store())
            } catch is CancellationError {
              return
            } catch {
              guard !Task.isCancelled else { return }
              guard let handler else {
                reportIssue(
                  """
                  An "Effect.run" returned from "\(fileID):\(line)" threw an unhandled error.

                  \(
                    String(customDumping: error)
                      .split(whereSeparator: { $0.isNewline })
                      .compactMap({ "    \($0)" })
                      .joined(separator: "\n")
                  )

                  All non-cancellation errors must be explicitly handled via the "catch" parameter \
                  on "Effect.run", or via a "do" block.
                  """,
                  fileID: fileID,
                  filePath: filePath,
                  line: line,
                  column: column
                )
                return
              }
              await handler(error, store ?? Store())
            }
          }
        }
      )
    }
  }

  public static func send(_ action: @autoclosure @escaping @Sendable () -> Action) -> Self {
    Self(operation: .run { $0.send(action()) })
  }

  public static func merge(_ effects: Self...) -> Self {
    Self.merge(effects)
  }

  public static func merge(_ effects: some Sequence<Self>) -> Self {
    effects.reduce(.none) { $0.merge(with: $1) }
  }

  public func merge(with other: Self) -> Self {
    switch (self.operation, other.operation) {
    case (_, .none):
      return self
    case (.none, _):
      return other
    case (
      .run(let lhsName, let lhsPriority, let lhsOperation),
      .run(let rhsName, let rhsPriority, let rhsOperation)
    ):
      return Self(
        operation: .run { store in
          await withTaskGroup(of: Void.self) { group in
            group.addTask(name: lhsName, priority: lhsPriority) {
              await lhsOperation(store)
            }
            group.addTask(name: rhsName, priority: rhsPriority) {
              await rhsOperation(store)
            }
          }
        }
      )
    }
  }

  public static func concatenate(_ effects: Self...) -> Self {
    Self.concatenate(effects)
  }

  public static func concatenate(_ effects: some Collection<Self>) -> Self {
    effects.reduce(.none) { $0.concatenate(with: $1) }
  }

  @_disfavoredOverload
  public func concatenate(with other: Self) -> Self {
    switch (self.operation, other.operation) {
    case (_, .none):
      return self
    case (.none, _):
      return other
    case (
      .run(let lhsName, let lhsPriority, let lhsOperation),
      .run(let rhsName, let rhsPriority, let rhsOperation)
    ):
      return Self(
        operation: .run { store in
          if let lhsPriority {
            await Task(name: lhsName, priority: lhsPriority) { await lhsOperation(store) }
              .cancellableValue
          } else {
            await lhsOperation(store)
          }
          if let rhsPriority {
            await Task(name: rhsName, priority: rhsPriority) { await rhsOperation(store) }
              .cancellableValue
          } else {
            await rhsOperation(store)
          }
        }
      )
    }
  }
}
