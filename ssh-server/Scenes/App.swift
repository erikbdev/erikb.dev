import SwiftTUITerminal

struct PortfolioApp: App {
  var body: some Scene {
    WindowGroup {
      PortfolioView()
    }
    .exitOnKey(.character("q"))
  }
}

// MARK: - Root

enum PortfolioTab: Hashable, Sendable, CaseIterable {
  case home
  case devLogs

  var title: String {
    switch self {
    case .home: "Home"
    case .devLogs: "Dev Logs"
    }
  }

  var command: String {
    switch self {
    case .home: "whoami"
    case .devLogs: "ls -l /dev-logs"
    }
  }
}

struct PortfolioView: View {
  @Environment(\.colorSchemeContrast) private var colorScheme
  @State private var tab: PortfolioTab = .home
  @State private var textInput = PortfolioTab.home.command

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        Text("erikb@dev:~")
          .bold()
        Text("$")
          .bold()
          .foregroundStyle(.yellow)

        TextField(text: $textInput) {
          EmptyView()
        }
        .textFieldStyle(.plain)
        .onKeyPress(.return) { _ in
          return resolveTabInput()
        }
        .onKeyPress(.tab) { _ in 
          return resolveTabInput(setCommand: false)
        }

        Spacer()
      }

      Divider()

      switch tab {
      case .home:
        HomeView()
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      case .devLogs:
        DevLogsView()
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      }

      Text("Press `q` to exit")
        .foregroundStyle(.black)
        .frame(maxWidth: .infinity)
        .background(.white)
    }
    .background(Color(white: 0.1))
  }

  private func resolveTabInput(setCommand: Bool = true) -> KeyPressResult {
    let trimmedTextInput = textInput.trimmingCharacters(in: .whitespacesAndNewlines)
    let newTab = PortfolioTab.allCases.first { $0.command.hasPrefix(trimmedTextInput) } ?? self.tab
    self.textInput = newTab.command
    if (setCommand) {
      self.tab = newTab
    }
    return .handled
  }
}
