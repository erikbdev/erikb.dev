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
  // let channel: AsyncChannel
  // let logger: Logger

  // init(_ channel: AsyncChannel) {
  //   self.channel = channel
  //   self.logger = logger
  // }

  enum Error: Swift.Error {
    case missingPseudoTerminalRequest
  }

  static func serve(_ channel: AsyncChannel) async {
    let logger = {
      var logger = Logger(label: "\(Self.self)")
      logger[metadataKey: "ip"] = "\(channel.channel.remoteAddress?.ipAddress ?? "unknown", privacy: .sensitive(mask: .hash))"
      return logger
    }()

    do {
      try await channel.executeThenClose { inbound, outbound in
        var iterator = inbound.makeAsyncIterator()

          do {
          guard case .event(.pseudoTerminal(let pseudoTerm)) = try await iterator.next() else {
            throw Error.missingPseudoTerminalRequest
          }

          logger.trace("Pseudo terminal request received", metadata: ["event": "\(pseudoTerm)"])

          while let next = try await iterator.next() {
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

          try await channel.channel.closeFuture.get()
        } catch {
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
          } else {
            try await outbound.write(
              .init(
                type: .channel,
                data: .byteBuffer(channel.channel.allocator.buffer(string: "An unexpected error occurred."))
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
