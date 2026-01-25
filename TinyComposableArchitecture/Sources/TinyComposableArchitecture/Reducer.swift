public protocol Reducer<State, Action> {
  associatedtype State
  associatedtype Action

  associatedtype Body

  func reduce(into state: inout State, action: Action) -> Effect<Action>

  @ReducerBuilder<State, Action>
  var body: Body { get }
}

extension Reducer where Body == Never {
  public var body: Body {
    fatalError(
      """
      '\(Self.self)' has no body. …

      Do not access a reducer's 'body' property directly, as it may not exist. To run a reducer, \
      call 'Reducer.reduce(into:action:)', instead.
      """
    )
  }
}

public typealias ReducerOf<R: Reducer> = Reducer<R.State, R.Action>

extension Reducer where Body: Reducer<State, Action> {
  public func reduce(into state: inout Body.State, action: Body.Action) -> Effect<Body.Action> {
    self.body.reduce(into: &state, action: action)
  }
}

@resultBuilder
public enum ReducerBuilder<State, Action> {
  public static func buildBlock() -> EmptyReducer<State, Action> {
    EmptyReducer()
  }

  public static func buildBlock<R: Reducer<State, Action>>(_ reducer: R) -> R {
    reducer
  }

  public static func buildExpression<R: Reducer<State, Action>>(_ expression: R) -> R {
    expression
  }
}
