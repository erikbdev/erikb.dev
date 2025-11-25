import ArgumentParser
import Crypto
import Foundation
import Logging
@preconcurrency import NIO
@preconcurrency import NIOSSH

let log = {
  var log = Logger(label: "dev.erikb.ssh")
  log.logLevel = .debug
  return log
}()

@main
struct Terminal: AsyncParsableCommand {
  @Option(name: .shortAndLong)
  var host = "0.0.0.0"

  @Option(name: .shortAndLong)
  var port = 2222

  #if !DEBUG
    @Option(name: .long, transform: URL.init(fileURLWithPath:))
    var privateKeyFile: URL
  #endif

  func run() async throws {
    LoggingSystem.bootstrap(StreamLogHandler.standardError(label:))
    let delegate = UserAuthDelegate()
    let hostKey: NIOSSHPrivateKey
    #if DEBUG
      hostKey = NIOSSHPrivateKey(ed25519Key: .init())
    #else
      hostKey = try NIOSSHPrivateKey(
        ed25519Key: Curve25519.Signing.PrivateKey(
          rawRepresentation: FileHandle(forReadingFrom: privateKeyFile)
            .readToEnd() ?? Data()
        )
      )
    #endif

    let bootstrap = ServerBootstrap(group: .singletonMultiThreadedEventLoopGroup)
      .serverChannelOption(.backlog, value: 256)
      .serverChannelOption(.socketOption(.so_reuseaddr), value: 1)
      // .serverChannelOption(.socketOption(.tcp_nodelay), value: 1)
      .childChannelInitializer { channel in
        channel.pipeline.eventLoop.makeCompletedFuture {
          try channel.pipeline.syncOperations.addHandler(
            NIOSSHHandler(
              role: .server(
                SSHServerConfiguration(
                  hostKeys: [hostKey],
                  userAuthDelegate: delegate,
                  globalRequestDelegate: nil,
                  banner: nil
                )
              ),
              allocator: channel.allocator,
            ) { child, type in
              child.pipeline.addHandler(InteractiveClient(type: type))
            }
          )
        }
      }
      .childChannelOption(.allowRemoteHalfClosure, value: true)

    let serverChannel = try await bootstrap
      .bind(host: host, port: port)
      .get()

    log.debug("SSH server listening on \(host):\(port))")
    try await serverChannel.closeFuture.get()
    try await serverChannel.eventLoop.shutdownGracefully()
  }
}
