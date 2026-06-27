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
  @FocusState private var commandInputFocused

  var body: some View {
    Group {
      // if showingSplash {
      // SplashView { showingSplash = false }
      // } else {
      // }
      VStack(alignment: .leading, spacing: 0) {
        ScrollView {
          // TODO: make command array based, each command having its own state.
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
          // .onKeyPress(.character("/")) { _ in
          //   guard !commandInputFocused else {
          //     return .ignored
          //   }
          //   commandInputFocused = true
          //   return .handled
          // }

          .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

        HStack(spacing: 0) {
          Text("> ")
            .foregroundStyle(.yellow)
          TextField(text: $commandInput, prompt: Text("type a command (e.g. /help)"), label: EmptyView.init)
            .focused($commandInputFocused)
            .textFieldStyle(.plain)
            .onKeyPress(.return) { _ in
              resolveCommandInput()
            }
            .prefersDefaultFocus(in: .default)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .border(.yellow, set: .rounded, placement: .outset)

        Text("* type /exit to quit")
          .foregroundStyle(Color(white: 0.4))
          .italic()
          .padding(.leading, 1)
      }
      .padding(0)
    }
    .environment(\.logger, logger)
    .environment(\.exitAction, exitAction)
  }

  private func resolveCommandInput() -> KeyPressResult {
    let trimmedTextInput = commandInput.trimmingCharacters(in: .whitespacesAndNewlines)
    let newCommand = PortfolioCommand.allCases.first { $0.command.hasPrefix(trimmedTextInput) }
    if newCommand == .exit {
      self.exitAction()
    } else if let newCommand, self.command != newCommand {
      self.command = newCommand
    } else {
      self.commandInput = ""
    }
    return .handled
  }
}
