public struct Reduce<State, Action>: Reducer {
  let reduce: (inout State, Action) -> Effect<Action>

  public init(_ operation: @escaping (_ state: inout State, _ action: Action) -> Effect<Action>) {
    self.reduce = operation
  }

  public init(_ reducer: some Reducer<State, Action>) {
    self.reduce = reducer.reduce
  }

  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    self.reduce(&state, action)
  }
}
