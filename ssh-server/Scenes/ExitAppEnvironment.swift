import SwiftTUI

struct ExitAppEnvironmentKey: EnvironmentKey {
  static let defaultValue: (@Sendable () -> Void) = {}
}

extension EnvironmentValues {
  var exitAction: @Sendable () -> Void {
    get { self[ExitAppEnvironmentKey.self] }
    set { self[ExitAppEnvironmentKey.self] = newValue }
  }
}