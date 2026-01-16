import ArgumentParser
import Crypto
import Foundation
import Logging
import NIO
import NIOCore
import NIOSSH

let logger = {
  LoggingSystem.bootstrap {
    var handler = StreamLogHandler.standardOutput(label: $0)
    #if DEBUG
      handler.logLevel = .trace
    #else
      handler.logLevel = .error
    #endif
    return handler
  }
  return Logger(label: "SSHServer")
}()

@main
struct SSHServer: AsyncParsableCommand {
  @Option(name: .shortAndLong)
  var host = "127.0.0.1"

  @Option(name: .shortAndLong)
  var port = 2222

  #if !DEBUG
    @Option(name: .long, transform: URL.init(fileURLWithPath:))
    var privateKeyFile: URL
  #endif

  func run() async throws {
    let delegate = UserAuthDelegate()
    #if DEBUG
      let hostKey = NIOSSHPrivateKey(ed25519Key: .init())
    #else
      let hostKey = try NIOSSHPrivateKey(
        ed25519Key: Curve25519.Signing.PrivateKey(
          rawRepresentation: FileHandle(forReadingFrom: privateKeyFile)
            .readToEnd() ?? Data()
        )
      )
    #endif

    let serverChannel = try await ServerBootstrap(group: .singletonMultiThreadedEventLoopGroup)
      .serverChannelOption(.backlog, value: 256)
      .serverChannelOption(.socketOption(.so_reuseaddr), value: 1)
      // .serverChannelOption(.socketOption(.tcp_nodelay), value: 1)
      .childChannelOption(.allowRemoteHalfClosure, value: true)
      .childChannelOption(.socketOption(.so_reuseaddr), value: 1)
      .bind(host: host, port: port) { channel in
        channel.configureSSHPipeline(
          role: .server(
            SSHServerConfiguration(
              hostKeys: [hostKey],
              userAuthDelegate: delegate,
              globalRequestDelegate: nil,
              banner: nil
            )
          )
        ) { channel, type in
          channel.eventLoop.makeCompletedFuture {
            guard type == .session else {
              throw SSHServerError.unsupportedSSHChannelType
            }
            return try NIOAsyncChannel(
              wrappingChannelSynchronously: channel,
              configuration: .init(
                inboundType: NIOSSHHandler.SSHChannelInboundData.self,
                outboundType: NIOSSHHandler.SSHChannelOutboundData.self
              )
            )
          }
        }
      }

    logger.info("SSH Server started", metadata: ["host": "\(host)", "port": "\(port)"])

    try await withThrowingDiscardingTaskGroup { group in
      try await serverChannel.executeThenClose { inbound in
        for try await (_, multiplexer) in inbound {
          group.addTask {
            do {
              try await withThrowingDiscardingTaskGroup { group in
                for try await childChannel in multiplexer.inbound {
                  group.addTask {
                    await ClientSession.serve(childChannel)
                  }
                }
              }
            } catch {
              logger.debug("Connection error", metadata: ["error": "\(error)"])
            }
          }
        }
      }
    }
  }
}
