import ArgumentParser
import Crypto
import Foundation
import Logging
@preconcurrency import NIO
import NIOCore
@preconcurrency import NIOSSH

let log = {
  var log = Logger(label: "dev.erikb.ssh")
  log.logLevel = .debug
  return log
}()

@main
struct SSHServer: AsyncParsableCommand {
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
      .childChannelOption(.allowRemoteHalfClosure, value: true)
    // .childChannelInitializer { channel in
    //   channel.pipeline.eventLoop.makeCompletedFuture {
    //     try channel.pipeline.syncOperations.addHandler(
    //       NIOSSHHandler(
    //         role: .server(
    //           SSHServerConfiguration(
    //             hostKeys: [hostKey],
    //             userAuthDelegate: delegate,
    //             globalRequestDelegate: nil,
    //             banner: nil
    //           )
    //         ),
    //         allocator: channel.allocator,
    //       ) { child, type in
    //         child.pipeline.addHandler(InteractiveClient(type: type))
    //       }
    //     )
    //   }
    // }

    let serverChannel = try await bootstrap.bind(host: host, port: port) { channel in
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
          ) { channel, type in
            channel.eventLoop.makeSucceededVoidFuture()
          }
        )
        return try NIOAsyncChannel<IOData, IOData>(wrappingChannelSynchronously: channel)
      }
    }

    log.info("SSH Server listening on \(host):\(port)")

    try await serverChannel.executeThenClose { inbound in
      try await withThrowingDiscardingTaskGroup { group in
        for try await client in inbound {
          group.addTask {
            try await client.executeThenClose { clientInbound, clientOutbound in
              log.info("SSH Client connected [\(client.channel.remoteAddress?.ipAddress ?? "")")

              try await withThrowingTaskGroup { group in
              // try await clientOutbound.write(.byteBuffer(ByteBuffer(string: "jhello")))

                // try await clientOutbound.write(.init(type: .channel, data: .byteBuffer(ByteBuffer(string: "Hello, Terminal!"))))
                group.addTask {
                  for try await input in clientInbound {
                    let string: String

                    switch input {
                    case .byteBuffer(let buffer):
                      string = String(buffer: buffer)
                    case .fileRegion(let file):
                      let fileIo = NonBlockingFileIO(threadPool: .singleton)
                      string = (try? await String(buffer: fileIo.read(fileRegion: file, allocator: client.channel.allocator))) ?? ""
                    }
                    log.debug("New input data: \(string)")
                  }
                }
                try await client.channel.closeFuture.get()
              }
            }
          }
        }
      }
    }
  }
}
