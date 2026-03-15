import ElementaryUI

#if !os(WASI)
  import Dependencies
#endif

#if os(WASI)
public protocol ClientKey {
  associatedtype Value
  static var defaultClient: Value { get }
}
#else
public protocol ClientKey: DependencyKey {
  static var defaultClient: Value { get }
}

extension ClientKey {
  public static var liveValue: Value { self.defaultClient }
}
#endif

public typealias ClientValues = EnvironmentValues

extension ClientKey {
  public static var defaultValue: Value { self.defaultClient }
}