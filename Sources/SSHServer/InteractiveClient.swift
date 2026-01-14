import Logging
import NIO
import NIOConcurrencyHelpers
import NIOSSH
@preconcurrency import SwiftTUI

private struct ClientState {
  let type: SSHChannelType

  var pty: SSHChannelRequestEvent.PseudoTerminalRequest?
  var hasPty: Bool { pty != nil }

  var application: Application?
}

struct ClientSession: Sendable {
  typealias AsyncChannel = NIOAsyncChannel<NIOSSHHandler.SSHChannelInboundData, NIOSSHHandler.SSHChannelOutboundData>
  let channel: AsyncChannel
  let logger: Logger

  init(_ channel: AsyncChannel) {
    self.channel = channel
    self.logger = Logger(
      label: "\(Self.self)", 
      metadataProvider: Logger.MetadataProvider { ["ip": "\(channel.channel.remoteAddress?.ipAddress ?? "unknown")"] }
    )
  }

  enum Error: Swift.Error {
    case missingPseudoTerminalRequest
  }

  func serve() async throws {
    try await channel.executeThenClose { inbound, outbound in
      logger.debug("New ssh session")

      var iterator = inbound.makeAsyncIterator()

      do {
        guard case .event(.pseudoTerminal(let pseudoTerm)) = try await iterator.next() else {
          throw Error.missingPseudoTerminalRequest
        }

        logger.debug("Received pseudo terminal request: \(pseudoTerm)")

        let application = Application(rootView: TerminalApp()) { string in
          channel.channel.write(
            NIOSSHHandler.SSHChannelOutboundData(type: .channel, data: .byteBuffer(channel.channel.allocator.buffer(string: string))),
            promise: nil
          )
        }
        // application.changeWindowsSize(
        //   to: Size(
        //     width: .init(pseudoTerm.terminalPixelWidth),
        //     height: .init(pseudoTerm.terminalPixelHeight)
        //   )
        // )

        application.start()

        while let next = try await iterator.next() {
          switch next {
          case .data(let data):
            logger.debug("Received data: \(data)")
            guard case .byteBuffer(let b) = data.data, data.type == .channel else {
              continue
            }
            application.handleInput(String(buffer: b))
          case .event(let event):
            logger.debug("Received event: \(event)")
            switch event {
            case .windowChange(let event):
              application.changeWindowsSize(
                to: Size(width: Extended(event.terminalCharacterWidth), height: Extended(event.terminalCharacterWidth))
              )
            case .exitSignal:
              application.stop()
              try await channel.channel.close()
            default:
              continue
            }
          }
        }

        try await channel.channel.closeFuture.get()
      } catch {
        logger.debug("An error occurred: \(error)")
        if let error = error as? Error {
          switch error {
          case .missingPseudoTerminalRequest:
            try await outbound.write(
              .init(
                type: .channel,
                data: .byteBuffer(channel.channel.allocator.buffer(string: "A pseudo terminal is requires to access this application."))
              )
            )
          }
        }
      }
      logger.debug("Closing ssh session")
    }
  }
}
