import Foundation
import Logging
import NIO
import NIOConcurrencyHelpers
import NIOSSH

private struct ClientState {
  let type: SSHChannelType

  var pty: SSHChannelRequestEvent.PseudoTerminalRequest?
  var hasPty: Bool { pty != nil }

}

enum ClientSession: Sendable {
  typealias AsyncChannel = NIOAsyncChannel<NIOSSHHandler.SSHChannelInboundData, NIOSSHHandler.SSHChannelOutboundData>

  enum Error: Swift.Error, CustomStringConvertible {
    case missingPseudoTerminalRequest
    case connectionUnexpectedClosed

    var description: String {
      switch self {
      case .missingPseudoTerminalRequest: "A pseudo terminal is requires to access this application."
      case .connectionUnexpectedClosed: "The connection unexpectedly closed."
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
        let iterator = UnsafeMutableTransferBox(inbound.makeAsyncIterator())

        do {
          guard case .event(.pseudoTerminal(let pseudoTerm)) = try await iterator.wrappedValue.next() else {
            throw Error.missingPseudoTerminalRequest
          }

          logger.trace("Pseudo terminal request received", metadata: ["event": "\(pseudoTerm)"])

          try await withFrameClock(fps: 10) { timestamp in
            logger.debug("Printing framerate \(timestamp)")
          } tasks: { group in
            group.addTask {
              while let next = try await iterator.wrappedValue.next() {
                logger.trace("New inbound event received", metadata: ["event": "\(next)"])
                switch next {
                case .data(let data):
                  guard case .byteBuffer(let b) = data.data, data.type == .channel else {
                    continue
                  }
                case .event(let event):
                  switch event {
                  case .windowChange(let event):
                    continue
                  case .exitSignal:
                    try await channel.channel.close()
                  default:
                    continue
                  }
                }
              }
            }
            group.addTask {
              try await channel.channel.closeFuture.get()
              throw Error.connectionUnexpectedClosed
            }
          }
        } catch {
          logger.debug("An error occurred during session", metadata: ["error": "\(error)"])
          if channel.channel.isWritable {
            try await outbound.write(
              .init(
                type: .channel,
                data: .byteBuffer(channel.channel.allocator.buffer(string: error.localizedDescription))
              )
            )
          }
          throw error
        }
      }
    } catch {
      logger.debug("An error occurred", metadata: ["error": "\(error)"])
    }
  }
}
