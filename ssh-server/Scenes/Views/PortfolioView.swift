import Logging
import SwiftTUITerminal

struct PortfolioView: View {
  enum CommandTip {
    case commandNotFound(String)
    case availableCommands([PortfolioCommand])
  }

  let logger: Logger
  let exitAction: @Sendable () -> Void
  @Environment(\.colorSchemeContrast) private var colorScheme
  @Environment(\.controlProminence) private var colorProminence
  @Environment(\.terminalAppearance) private var appearance

  @State private var showingSplash = true
  @State private var command: PortfolioCommand = .home
  @State private var commandInput = ""
  @State private var commandTip: CommandTip?
  @FocusState private var commandInputFocused

  var body: some View {
    // if showingSplash {
    // SplashView { showingSplash = false }
    // } else {
    // }
    VStack(alignment: .leading, spacing: 0) {
      Group {
        switch command {
        case .home:
          HomeView()
        case .devlogs:
          DevLogsView()
        default:
          EmptyView()
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

      VStack(alignment: .leading, spacing: 0) {
        HStack(spacing: 0) {
          Text("erikb@dev:$ ")
            .foregroundStyle(commandInputFocused ? .yellow : .gray)
          TextField(text: $commandInput, prompt: Text("type a command (e.g. help)"), label: EmptyView.init)
            .defaultFocus($commandInputFocused)
            .prefersDefaultFocus(in: .default)
            .textFieldStyle(.plain)
            .onKeyPress(.return) { _ in
              resolveCommandInput()
            }
            .onKeyPress(.tab) { _ in
              resolveCommandInputTabbed()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        switch commandTip {
        case .commandNotFound(let command):
          Text("command not found: \"\(command)\", type \"help\" for commands ")
            .foregroundStyle(.red)
        case .availableCommands(let availableCommands):
          Group {
            Text("available commands:")
            ForEach(availableCommands, id: \.self) { command in
              Text("\(command.rawValue) // \(command.title)")
                .padding(.leading, 2)
            }
          }
          .foregroundStyle(Color(white: 0.5))
        case .none:
          EmptyView()
        }
      }
      .border(commandInputFocused ? .yellow : .gray, set: .rounded, placement: .outset)

      VStack(spacing: 0) {
        Text(
          "\(Text("↑/↓").foregroundStyle(.white)) navigate | \(Text("enter").foregroundStyle(.white)) select"
        )
        .foregroundStyle(Color(white: 0.5))
        .italic()
      }
      .padding(.leading, 1)
    }
    .padding(0)
    .environment(\.logger, logger)
    .environment(\.exitAction, exitAction)
  }

  private func resolveCommandInput() -> KeyPressResult {
    let trimmedTextInput = commandInput.trimmingCharacters(in: .whitespacesAndNewlines)
    self.commandTip = nil
    let newCommand = PortfolioCommand.allCases.first { $0.command == trimmedTextInput }
    if newCommand == .exit {
      self.exitAction()
    } else if newCommand == .help {
      self.commandTip = .availableCommands(PortfolioCommand.allCases)
    } else if let newCommand, self.command != newCommand {
      self.command = newCommand
    } else if newCommand == nil {
      self.commandTip = .commandNotFound(trimmedTextInput)
    }
    self.commandInput = ""
    return .handled
  }

  private func resolveCommandInputTabbed() -> KeyPressResult {
    let trimmedTextInput = commandInput.trimmingCharacters(in: .whitespacesAndNewlines)
    let matchedCommands = PortfolioCommand.allCases.filter { $0.command.hasPrefix(trimmedTextInput) }
    self.commandTip = nil
    guard !trimmedTextInput.isEmpty && !matchedCommands.isEmpty else {
      return .ignored
    }
    if matchedCommands.count > 1 {
      self.commandTip = .availableCommands(matchedCommands)
    } else if let matchedCommand = matchedCommands.first {
      self.commandInput = matchedCommand.command
    }
    return .handled
  }
}
