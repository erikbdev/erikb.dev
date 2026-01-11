import ArgumentParser
import Crypto
import Foundation
import Logging
import NIO
import NIOCore
import NIOSSH

let log = {
  LoggingSystem.bootstrap(StreamLogHandler.standardError(label:))
  var log = Logger(label: "dev.erikb.ssh")
  log.logLevel = .debug
  return log
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
          ),
          allocator: channel.allocator,
        ) { channel, type in
          channel.eventLoop.makeCompletedFuture {
            guard type == .session else {
              throw SSHServerError.unsupportedSSHChannelType
            }
            return try NIOAsyncChannel<SSHChannelData, SSHChannelData>(wrappingChannelSynchronously: channel)
          }
        }
      }

    log.info("SSH Server listening on \(host):\(port)")

    try await withThrowingDiscardingTaskGroup { group in
      try await serverChannel.executeThenClose { inbound in
        for try await (parentChannel, multiplexer) in inbound {
          log.debug("SSH client connected", metadata: ["ip": "\(parentChannel.remoteAddress?.ipAddress ?? "")"])
          group.addTask {
            try await withThrowingDiscardingTaskGroup { group in
              for try await child in multiplexer.inbound {
                group.addTask {
                  try await child.executeThenClose { inbound, outbound in
                    try await withThrowingTaskGroup(of: Void.self) { group in
                      log.debug("New ssh session", metadata: ["ip": "\(child.channel.remoteAddress?.ipAddress ?? "")"])
                      group.addTask {
                        for await event in try await child.channel.requestEvents.get() {
                          log.debug("Event: \(event)", metadata: ["ip": "\(child.channel.remoteAddress?.ipAddress ?? "")"])
                        }
                        log.debug("Event stream finished", metadata: ["ip": "\(child.channel.remoteAddress?.ipAddress ?? "")"])
                      }
                      group.addTask {
                        for try await data in inbound {
                          log.debug("Data: \(data)", metadata: ["ip": "\(child.channel.remoteAddress?.ipAddress ?? "")"])
                        }
                        log.debug("Data stream finished", metadata: ["ip": "\(child.channel.remoteAddress?.ipAddress ?? "")"])
                      }
                      try await group.waitForAll()
                    }
                    log.debug("SSH session finished", metadata: ["ip": "\(child.channel.remoteAddress?.ipAddress ?? "")"])
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
