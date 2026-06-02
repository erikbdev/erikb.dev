import Foundation
import Logging
import NIO
import NIOSSH
@_spi(Runners) import SwiftTUIRuntime

enum ClientSession {
  typealias AsyncChannel = NIOAsyncChannel<
    NIOSSHHandler.SSHChannelInboundData,
    NIOSSHHandler.SSHChannelOutboundData
  >

  struct Error: Swift.Error, CustomStringConvertible, LocalizedError {
    var code: Code
    var caught: Swift.Error?

    init(_ code: Code, caught error: Swift.Error? = nil) {
      self.code = code
      self.caught = error
    }

    var description: String {
      "\(String(reflecting: code))\(caught.map { " Error: \($0)" } ?? "")"
    }

    var errorDescription: String { code.localizedDescription }

    enum Code: Hashable, Sendable, LocalizedError {
      case missingPseudoTerminalRequest
      case connectionClosed
      case appInitializationFailed
      case unknown

      var errorDescription: String {
        switch self {
        case .missingPseudoTerminalRequest: "A pseudo terminal is required to access this application."
        case .connectionClosed: "The connection unexpectedly closed."
        case .appInitializationFailed, .unknown: "An unknown error occurred."
        }
      }
    }
  }

  static func serve(_ channel: AsyncChannel) async {
    let logger = {
      var logger = Logger(label: "\(Self.self)")
      logger[metadataKey: "ip"] = "\(channel.channel.remoteAddress?.ipAddress ?? "unknown")"
      return logger
    }()

    do {
      try await channel.executeThenClose { inbound, outbound in
        defer { logger.trace("Closing connection") }
        do {
          try await withThrowingTaskGroup(of: Void.self) { group in
            defer { group.cancelAll() }

            var iterator = inbound.makeAsyncIterator()

            // SSH clients must request a PTY before the TUI can start.
            guard case .event(.pseudoTerminal(let pty)) = try await iterator.next() else {
              throw Error(.missingPseudoTerminalRequest)
            }

            logger.trace(
              "PTY request",
              metadata: [
                "term": "\(pty.term)",
                "cols": "\(pty.terminalCharacterWidth)",
                "rows": "\(pty.terminalRowHeight)",
              ]
            )

            let surface = SSHPresentationSurface(
              columns: pty.terminalCharacterWidth,
              rows: pty.terminalRowHeight,
              environment: ["TERM": pty.term]
            )
            let inputReader = SSHInputReader()
            let signalReader = InProcessSignalReader()

            defer {
              surface.finish()
              inputReader.finish()
              signalReader.finish()
            }

            // Forward rendered ANSI frames to the SSH channel.
            group.addTask {
              for await frame in surface.outputStream {
                try await outbound.write(.init(type: .channel, data: .byteBuffer(frame)))
              }
            }

            // Run App
            group.addTask {
              try await run(
                app: PortfolioApp(),
                surface: surface,
                inputReader: inputReader,
                signalReader: signalReader,
                term: pty.term
              )
            }

            // Forward SSH input bytes to SwiftTUI and handle resize events.
            group.addTask {
              while let next = try await iterator.next() {
                switch next {
                case .data(let data):
                  guard case .byteBuffer(let buf) = data.data, data.type == .channel else {
                    continue
                  }
                  inputReader.receive(Array(buf.readableBytesView))

                case .event(.windowChange(let wc)):
                  surface.resize(
                    columns: wc.terminalCharacterWidth,
                    rows: wc.terminalRowHeight
                  )
                  signalReader.send("SIGWINCH")
                  break

                case .event(.environment(let env)):
                  surface.addEnvironment(name: env.name, value: env.value)
                  break

                default:
                  break
                }
              }
            }

            // Treat remote channel closure as a structured exit.
            group.addTask {
              try await channel.channel.closeFuture.cancellableGet()
              throw Error(.connectionClosed)
            }

            // Block until the first task completes or throws.
            try await group.next()
          }
        } catch {
          let error = error as? Error ?? Error(.unknown, caught: error)
          if channel.channel.isActive, channel.channel.isWritable {
            try await outbound.write(
              .init(
                type: .channel,
                data: .byteBuffer(channel.channel.allocator.buffer(string: error.errorDescription))
              )
            )
          }
          throw error
        }
      }
    } catch {
      logger.debug("\(error)")
    }
  }

  @MainActor
  private static func run<A: App>(
    app: A,
    surface: SSHPresentationSurface,
    inputReader: SSHInputReader,
    signalReader: InProcessSignalReader,
    term: String
  ) async throws {
    let selections = collectWindowSceneSelections(from: app.body)
    guard let selection = selections.first else {
      throw Error(.appInitializationFailed)
    }
    _ = try await selection.run(
      sessionName: String(reflecting: PortfolioApp.self),
      resources: SceneSessionResources(
        presentationSurface: surface,
        terminalInputReader: inputReader,
        signalReader: signalReader,
        environmentValues: ["TERM": term]
      ),
      stateContainer: StateContainer(
        initialState: SceneSessionState(),
        invalidationIdentities: [selection.rootIdentity]
      ),
      focusTracker: FocusTracker(
        invalidationIdentities: [selection.rootIdentity]
      )
    )
  }
}