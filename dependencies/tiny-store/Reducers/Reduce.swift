public struct Reduce<State, Action>: Reducer {
  let reduce: (inout State, Action) -> Effect<State, Action>

  public init(_ operation: @escaping (_ state: inout State, _ action: Action) -> Effect<State, Action>) {
    self.reduce = operation
  }

  public init(_ reducer: some Reducer<State, Action>) {
    self.reduce = reducer.reduce
  }

  public func reduce(into state: inout State, action: Action) -> Effect<State, Action> {
    self.reduce(&state, action)
  }
}
