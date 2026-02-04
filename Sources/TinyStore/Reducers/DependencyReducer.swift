import Dependencies

public struct _DependencyKeyWritingReducer<Base: Reducer>: Reducer {
  let base: Base
  let update: (inout DependencyValues) -> Void

  public func reduce(into state: inout Base.State, action: Base.Action) -> EffectOf<Base> {
    withDependencies {
      self.update(&$0)
    } operation: {
      self.base.reduce(into: &state, action: action)
    }
  }

  public func dependency<Value>(
    _ keyPath: WritableKeyPath<DependencyValues, Value>,
    _ value: Value
  ) -> Self {
    Self(base: self.base) {
      $0[keyPath: keyPath] = value
      self.update(&$0)
    }
  }
}

extension Reducer {
  public func dependency<Value>(
    _ keyPath: WritableKeyPath<DependencyValues, Value>,
    _ value: Value
  ) -> _DependencyKeyWritingReducer<Self> {
    _DependencyKeyWritingReducer(base: self) {
      $0[keyPath: keyPath] = value
    }
  }
}
