public struct EmptyReducer<State, Action>: Reducer {
  public init() {}

  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    .none
  }
}
