struct PortfolioCommand: Hashable, Sendable, CaseIterable {
  let title: String
  let rawValue: String

  var command: String { "/" + self.rawValue }

  static let home = Self(title: "Home", rawValue: "whoami")
  static let devlogs = Self(title: "Dev Logs", rawValue: "dev-logs")
  static let exit = Self(title: "Exit", rawValue: "exit")
  static let help = Self(title: "Help", rawValue: "help")

  static let allCases: [PortfolioCommand] = [
    home,
    devlogs,
    exit,
    help
  ]
}