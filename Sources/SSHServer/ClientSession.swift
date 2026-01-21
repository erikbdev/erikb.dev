import Foundation
import Logging
import NIO
import NIOConcurrencyHelpers
import NIOSSH

enum ClientSession: Sendable {
  typealias AsyncChannel = NIOAsyncChannel<NIOSSHHandler.SSHChannelInboundData, NIOSSHHandler.SSHChannelOutboundData>

  struct Error: Swift.Error, CustomStringConvertible, LocalizedError {
    var errorDescription: String
    var caught: Swift.Error?

    var description: String {
      "\(errorDescription)\(caught.map { " Error: \($0)" } ?? "")"
    }

    static func missingPseudoTerminalRequest(_ underlyingError: Swift.Error? = nil) -> Self {
      Self(errorDescription: "A pseudo terminal is required to access this application.", caught: underlyingError)
    }

    static func connectionUnexpectedClosed(_ underlyingError: Swift.Error? = nil) -> Self {
      Self(errorDescription: "The connection unexpectedly closed.", caught: underlyingError)
    }

    static func unknown(_ underlyingError: Swift.Error) -> Self {
      Self(errorDescription: "An unknown error occurred.", caught: underlyingError)
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
            throw Error.missingPseudoTerminalRequest()
          }

          // let app = App()

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
              throw Error.connectionUnexpectedClosed()
            }
          }
        } catch {
          let error = error as? ClientSession.Error ?? ClientSession.Error.unknown(error)
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
