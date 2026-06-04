import SwiftTUITerminal

@MainActor
struct PortfolioApp: App {

  // nonisolated init() {}

  var body: some Scene {
    WindowGroup {
      PortfolioView()
    }
    .exitOnKey(.character("q"))
  }
}

// MARK: - Root

enum PortfolioTab: Hashable, Sendable, CaseIterable {
  case home, devLogs

  var title: String {
    switch self {
    case .home: "Home"
    case .devLogs: "Dev Logs"
    }
  }
}

struct PortfolioView: View {
  @State private var tab: PortfolioTab = .home

  var body: some View {
    VStack(spacing: 0) {
      navBar
      Divider()

      // if tab == .home {
      //   HomeView()
      //     .frame(maxWidth: .infinity, maxHeight: .infinity)
      // } else {
      //   DevLogsView()
      //     .frame(maxWidth: .infinity, maxHeight: .infinity)
      // }
      TabView(selection: $tab) {
        Tab("home", detail: "(h)", value: PortfolioTab.home) {
          HomeView()
        }
        Tab("dev-logs", detail: "(l)", value: PortfolioTab.devLogs) {
          DevLogsView()
        }
      }
      .tabViewStyle(.powerline)
    }
    .onKeyPress(.character("h")) { _ in
      tab = .home
      return .handled
    }
    .onKeyPress(.character("l")) { _ in
      tab = .devLogs
      return .handled
    }
  }

  private var navBar: some View {
    HStack {
      Text("erikb@dev:~")
        .bold()
      Text("$")
        .bold()
        .foregroundStyle(.green)
      switch tab {
      case .home:
        Text("whoami")
      case .devLogs:
        Text("ls -l /dev-logs")
      }
      Spacer()
    }
    .padding(.horizontal)
  }
}
