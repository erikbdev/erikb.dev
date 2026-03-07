import Dependencies

struct TerminalAction: Sendable {
  private let callback: @Sendable () -> Void

  init(_ callback: @escaping @Sendable () -> Void) {
    self.callback = callback
  }

  func callAsFunction() {
    callback()
  }
}

private struct CloseAppTerminalAction: DependencyKey {
    static let liveValue = TerminalAction {} 
}

extension DependencyValues {
  var exitApp: TerminalAction {
    get { self[CloseAppTerminalAction.self] }
    set { self[CloseAppTerminalAction.self] = newValue }
  }
}