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
    let logLevel = ProcessInfo.processInfo.environment["LOG_LEVEL"]
      .flatMap { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
      .flatMap(Logger.Level.init(rawValue:))
    #if DEBUG
      handler.logLevel = logLevel ?? .trace
    #else
      handler.logLevel = logLevel ?? .error
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

  enum Error: Swift.Error {
    case unsupportedChannelType
  }

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
              throw Error.unsupportedChannelType
            }
            return try ClientSession.AsyncChannel(wrappingChannelSynchronously: channel)
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
              logger.debug("Client connection error", metadata: ["error": "\(error)"])
            }
          }
        }
      }
    }
  }
}

#if os(Linux)
  // https://github.com/swiftlang/swift/pull/77890
  // On Swift 6.2.1 on Linux, Observation runs into a linker error that swift::threading::fatal can't be found.
  // Seems to happen again when running test cases. So, stub it out.
  @_cdecl("_ZN5swift9threading5fatalEPKcz") func swift_threading_fatal() { fatalError("swift::threading::fatal") }
#endif
