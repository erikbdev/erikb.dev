#if canImport(Dependencies)
@_exported import class Dependencies.LockIsolated
#else 
public final class LockIsolated<Value: Sendable>: @unchecked Sendable {
  private var value: Value

  public init(_ value: Value) {
    self.value = value
  }

  public func withValue<R>(_ operation: @Sendable (inout Value) -> R) -> R {
    operation(&value)
  }
}
#endif
