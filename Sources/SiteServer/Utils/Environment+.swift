import Dependencies
import Hummingbird

private enum EnvKeys {
  static let appSecret = "APP_SECRET"
  static let basicAuthUsername = "BASIC_AUTH_USER"
  static let basicAuthPassword = "BASIC_AUTH_PASSWD"
}

extension Environment {
  public var appSecret: String {
    self.get(EnvKeys.appSecret) ?? "deadbeefdeadbeefdeadbeefdeadbeef"
  }

  public var basicAuth: (String, String) {
    (self.get(EnvKeys.basicAuthUsername) ?? "dead", self.get(EnvKeys.basicAuthPassword) ?? "beef")
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
