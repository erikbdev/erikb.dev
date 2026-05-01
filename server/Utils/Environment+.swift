import Dependencies
import Hummingbird

private enum EnvKeys {
  static let basicAuthUsername = "BASIC_AUTH_USER"
  static let basicAuthPassword = "BASIC_AUTH_PASSWD"
}

extension Environment {
  public var basicAuth: (String, String) {
    guard let username = self.get(EnvKeys.basicAuthUsername),
      let password = self.get(EnvKeys.basicAuthPassword),
      !username.isEmpty,
      !password.isEmpty else {
        #if DEBUG
        return ("deadbeef", "deadbeef")
        #else
        fatalError("Basic auth is empty")
        #endif
      }
      return (username, password)
  }
}

private struct EnvironmentKey: TestDependencyKey {
  static let testValue = Environment()
}

extension DependencyValues {
  public var envVars: Environment {
    get { self[EnvironmentKey.self] }
    set { self[EnvironmentKey.self] = newValue }
  }
}
