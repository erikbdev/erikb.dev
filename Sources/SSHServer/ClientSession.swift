import Foundation
import Logging
import NIO
import NIOConcurrencyHelpers
import NIOSSH
import TauTUI
import TinyStore

enum ClientSession: Sendable {
  typealias AsyncChannel = NIOAsyncChannel<NIOSSHHandler.SSHChannelInboundData, NIOSSHHandler.SSHChannelOutboundData>

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
      case unknown

      var errorDescription: String {
        switch self {
        case .missingPseudoTerminalRequest: "A pseudo terminal is required to access this application."
        case .connectionClosed: "The connection unexpectedly closed."
        case .unknown: "An unknown error occurred."
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

            group.addTask {
              var iterator = inbound.makeAsyncIterator()

              guard case .event(.pseudoTerminal(let pseudoTerm)) = try await iterator.next() else {
                throw Error(.missingPseudoTerminalRequest)
              }

              logger.trace("Pseudo terminal request received", metadata: ["event": "\(pseudoTerm)"])

              let terminal = RemoteTerminal(
                App(
                  store: Store(initialState: App.Feature.State()) {
                    App.Feature()
                  } withDependencies: {
                    $0.exitApp = TerminalAction { 
                      channel.channel.close(promise: nil)
                    }
                  }
                ),
                writer: outbound,
                environment: ["TERM": pseudoTerm.term],
                columns: pseudoTerm.terminalCharacterWidth,
                rows: pseudoTerm.terminalRowHeight
              )

              try await terminal.start()

              while let next = try await iterator.next() {
                switch next {
                case .data(let data):
                  guard case .byteBuffer(let b) = data.data, data.type == .channel else {
                    continue
                  }
                  try await terminal.parse(b)
                case .event(let event):
                  logger.trace("New inbound event received", metadata: ["event": "\(event)"])
                  switch event {
                  case .windowChange(let event):
                    try await terminal.resize(columns: event.terminalCharacterWidth, rows: event.terminalRowHeight)
                  case .environment(let environment):
                    try await terminal.addEnvironment(name: environment.name, value: environment.value)
                  case .exitSignal:
                    try await channel.channel.close()
                  case .exitStatus:
                    try await channel.channel.close()
                  default:
                    continue
                  }
                }
              }
            }
            group.addTask {
              try await channel.channel.closeFuture.cancellableGet()
              throw Error(.connectionClosed)
            }

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
}
