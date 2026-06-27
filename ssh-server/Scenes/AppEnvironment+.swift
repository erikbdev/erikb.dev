import Logging
import SwiftTUI

private struct ExitAppEnvironmentKey: EnvironmentKey {
  static let defaultValue: (@Sendable () -> Void) = {}
}

extension EnvironmentValues {
  var exitAction: @Sendable () -> Void {
    get { self[ExitAppEnvironmentKey.self] }
    set { self[ExitAppEnvironmentKey.self] = newValue }
  }
}

private struct AppLoggerEnvironmentKey: EnvironmentKey {
  static let defaultValue = logger
}

extension EnvironmentValues {
  var logger: Logger {
    get { self[AppLoggerEnvironmentKey.self] }
    set { self[AppLoggerEnvironmentKey.self] = newValue }
  }
}