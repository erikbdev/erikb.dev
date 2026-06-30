import Logging
import SwiftTUITerminal

struct PortfolioView: View {
  let logger: Logger
  let exitAction: @Sendable () -> Void
  @Environment(\.colorSchemeContrast) private var colorScheme
  @Environment(\.controlProminence) private var colorProminence
  @Environment(\.terminalAppearance) private var appearance

  @State private var showingSplash = true
  @State private var command: PortfolioCommand = .home
  @State private var commandInput = ""
  @State private var commandNotFound = ""
  @State private var showHelpCommand = false
  @FocusState private var commandInputFocused

  var body: some View {
    // if showingSplash {
    // SplashView { showingSplash = false }
    // } else {
    // }
    VStack(alignment: .leading, spacing: 0) {
      ScrollView {
        Group {
          Text("> \(command.rawValue)")
          switch command {
          case .home:
            HomeView()
          case .devlogs:
            DevLogsView()
          default:
            EmptyView()
          }
        }

        .frame(maxWidth: .infinity)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

      VStack(alignment: .leading, spacing: 0) {
        HStack(spacing: 0) {
          Text("erikbdev@portfolio:$ ")
            .foregroundStyle(.yellow)
          TextField(text: $commandInput, prompt: Text("type a command (e.g. help)"), label: EmptyView.init)
            .focused($commandInputFocused)
            .textFieldStyle(.plain)
            .onKeyPress(.return) { _ in
              resolveCommandInput()
            }
            .onKeyPress(.tab) { _ in
              .handled
            }
            .prefersDefaultFocus(in: .default)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        if commandNotFound.count > 0 {
          Text("command not found: \"\(commandNotFound)\", type \"help\" for commands ")
            .foregroundStyle(.red)
          // .padding(.top, 1)
        }

        if showHelpCommand {
          Group {
            Text("available commands:")
            // .padding(.top, 1)
            ForEach(PortfolioCommand.allCases, id: \.self) { command in
              Text("  \(command.rawValue) // \(command.title)")
            }
          }
          .foregroundStyle(Color(white: 0.5))
        }
      }
      .border(commandInputFocused ? .yellow : .gray, set: .rounded, placement: .outset)

      VStack(spacing: 0) {
        if !commandNotFound.isEmpty {
        }
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
    self.showHelpCommand = false
    self.commandNotFound = ""
    let newCommand = PortfolioCommand.allCases.first { $0.command == trimmedTextInput }
    if newCommand == .exit {
      self.exitAction()
    } else if newCommand == .help {
      showHelpCommand = true
    } else if let newCommand, self.command != newCommand {
      self.command = newCommand
    } else if newCommand == nil {
      self.commandNotFound = trimmedTextInput
    }
    self.commandInput = ""
    return .handled
  }
}
