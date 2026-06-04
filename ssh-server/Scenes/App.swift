import SwiftTUITerminal

@MainActor
struct PortfolioApp: App {
  nonisolated init() {}

  var body: some Scene {
    WindowGroup {
      PortfolioView()
    }
    .exitOnKey(.character("q"), modifiers: .ctrl)
  }
}

// MARK: - Root

enum PortfolioTab: Hashable, Sendable {
  case home, devLogs
}

struct PortfolioView: View {
  @State private var tab: PortfolioTab = .home

  var body: some View {
    VStack(spacing: 0) {
      statusBar
      navBar
      Divider()
      TabView(selection: $tab) {
        Tab("~/home", value: PortfolioTab.home) { HomeView() }
        Tab("~/dev-logs", value: PortfolioTab.devLogs) { DevLogsView() }
      }
    }
  }

  private var statusBar: some View {
    HStack {
      Text("TERM xterm-256color  TTY0  connection opened")
        .foregroundStyle(.gray)
        .faint()
      Spacer()
      Text("^Q quit")
        .foregroundStyle(.gray)
        .faint()
    }
    .padding(.horizontal)
  }

  private var navBar: some View {
    HStack {
      Text("erikb@dev:~")
        .bold()
      Text("$")
        .bold()
        .foregroundStyle(.green)
      Spacer()
    }
    .padding(.horizontal)
  }
}
