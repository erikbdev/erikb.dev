import SwiftTUITerminal

struct PortfolioApp: Scene {
  @State var exitCallback: @Sendable () -> Void

  var body: some Scene {
    WindowGroup { [exitCallback] in
      PortfolioView()
        .environment(\.exitAction, exitCallback)
    }
  }
}

// MARK: - Root

enum PortfolioTab: Hashable, Sendable, CaseIterable {
  case home
  case devLogs
  case exit

  var title: String {
    switch self {
    case .home: "Home"
    case .devLogs: "Dev Logs"
    case .exit: ""
    }
  }

  var command: String {
    switch self {
    case .home: "/whoami"
    case .devLogs: "/dev-logs"
    case .exit: "/exit"
    }
  }
}

struct PortfolioView: View {
  @Environment(\.colorSchemeContrast) private var colorScheme
  @Environment(\.controlProminence) private var colorProminence
  @Environment(\.terminalAppearance) private var appearance
  @Environment(\.exitAction) private var exitAction

  @State private var tab: PortfolioTab = .home
  @State private var commandInput = ""

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      switch tab {
      case .home:
        HomeView()
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      case .devLogs:
        DevLogsView()
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      case .exit:
        EmptyView()
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      }

      TextField(text: $commandInput, prompt: Text("type a command"), label: EmptyView.init)
        .textFieldStyle(.plain)
        .onKeyPress(.return) { _ in
          resolveCommandInput()
        }
        .padding(1)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.gray.opacity(0.25))

      Text("type `/exit` to exit")
        .foregroundStyle(.gray.opacity(0.5))
        .italic()
    }
    .padding(0)
    .foregroundStyle(appearance.backgroundColor.contrastRatio(to: .white) > 0.5 ? .black : .white)
  }

  private func resolveCommandInput(setCommand: Bool = true) -> KeyPressResult {
    let trimmedTextInput = commandInput.trimmingCharacters(in: .whitespacesAndNewlines)
    let newTab = PortfolioTab.allCases.first { $0.command.hasPrefix(trimmedTextInput) } ?? self.tab
    self.tab = newTab
    if newTab == .exit {
      self.exitAction()
    }
    return .handled
  }
}
