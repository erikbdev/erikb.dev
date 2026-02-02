import Foundation
import Logging
import NIO
import NIOConcurrencyHelpers
import NIOSSH
import TinyComposableArchitecture

enum ClientSession: Sendable {
  typealias AsyncChannel = NIOAsyncChannel<NIOSSHHandler.SSHChannelInboundData, NIOSSHHandler.SSHChannelOutboundData>

  struct Error: Swift.Error, CustomStringConvertible, LocalizedError {
    var backing: Backing
    var caught: Swift.Error?

    init(_ backing: Backing, caught error: Swift.Error? = nil) {
      self.backing = backing
      self.caught = error
    }

    var description: String {
      "\(backing.description)\(caught.map { " Error: \($0)" } ?? "")"
    }

    var errorDescription: String { backing.description }

    enum Backing: Hashable, Sendable {
      case missingPseudoTerminalRequest
      case connectionClosed
      case unknown

      var description: String {
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
        let iterator = UnsafeMutableTransferBox(inbound.makeAsyncIterator())

        do {
          guard case .event(.pseudoTerminal(let pseudoTerm)) = try await iterator.wrappedValue.next() else {
            throw Error(.missingPseudoTerminalRequest)
          }

          logger.trace("Pseudo terminal request received", metadata: ["event": "\(pseudoTerm)"])

          let app = App(
            store: Store(initialState: App.Feature.State()) {
              App.Feature()
            }
          )

          let renderer = VTRenderer(Size(width: pseudoTerm.terminalPixelWidth, height: pseudoTerm.terminalPixelHeight)) { bytes in
            try await outbound.write(.init(type: .channel, data: .byteBuffer(bytes)))
          }

          try await outbound.write(
            .init(
              type: .channel,
              data: .byteBuffer(ByteBuffer(string: ControlSequence.SetMode([.DEC(.UseAlternateScreenBufferSaveCursor)]).encoded(as: .b7)))
            )
          )

          try await withThrowingTaskGroup(of: Void.self) { group in
            defer { group.cancelAll() }
            group.addTask {
              renderer.back.clear()
              app.render(into: &renderer.back)
              await renderer.present()
              for await _ in app.store.didSet {
                renderer.back.clear()
                app.render(into: &renderer.back)
                await renderer.present()
              }
            }
            group.addTask {
              var parser = TerminalInputParser()

              while let next = try await iterator.wrappedValue.next() {
                switch next {
                case .data(let data):
                  guard case .byteBuffer(let b) = data.data, data.type == .channel else {
                    continue
                  }

                  for event in parser.parse(b) {
                    logger.debug("Received parsed event", metadata: ["event": "\(event)"])
                    await app.store.send(.event(.key(event)))
                  }
                case .event(let event):
                  logger.trace("New inbound event received", metadata: ["event": "\(event)"])
                  switch event {
                  case .windowChange(let event):
                    renderer.back.resize(to: Size(width: event.terminalPixelWidth, height: event.terminalPixelHeight))
                    renderer.back.clear()
                    app.render(into: &renderer.back)
                    await renderer.present()
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
              try await channel.channel.closeFuture.get()
              throw Error(.connectionClosed)
            }

            // TODO: fix store not deinit.
            do {
              try await group.waitForAll()
              await app.store.finish()
            } catch {
              await app.store.finish()
              throw error
            }
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
