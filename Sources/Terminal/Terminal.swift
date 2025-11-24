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
    let delegate = ServerUserAuthDelegate()
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

    let eventLoop = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    let bootstrap = ServerBootstrap(group: eventLoop)
      .serverChannelOption(.backlog, value: 256)
      .serverChannelOption(.socketOption(.so_reuseaddr), value: 1)
      .childChannelInitializer { channel in
        do {
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
              child.pipeline.addHandler(ClientSessionHandler())
            }
          )
          return channel.eventLoop.makeSucceededVoidFuture()
        } catch {
          return channel.eventLoop.makeFailedFuture(error)
        }
      }

    do {
      let serverChannel =
        try await bootstrap
        .bind(host: host, port: port)
        .get()

      log.debug("SSH server listening on \(String(describing: serverChannel.localAddress))")
      try await serverChannel.closeFuture.get()
    } catch {
      log.debug("Failed to start SSH server: \(error)")
    }

    do {
      try await eventLoop.shutdownGracefully()
    } catch {
      log.debug("Shutdown failed: \(error)")
    }
  }
}

private final class ClientSessionHandler: ChannelDuplexHandler, Sendable {
  typealias InboundIn = SSHChannelData
  typealias InboundOut = SSHChannelData
  typealias OutboundIn = SSHChannelData
  typealias OutboundOut = SSHChannelData

  func handlerAdded(context: ChannelHandlerContext) {
    context.channel.setOption(.allowRemoteHalfClosure, value: true).flatMapError { _ in
      context.channel.close(mode: .all)
    }
  }

  func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
    // log.debug("Client event: \(event)")
    switch event {
    case let event as SSHChannelRequestEvent.ExecRequest:
      log.debug("Client exec request event: \(context.remoteAddress?.description ?? "")")
    case let event as SSHChannelRequestEvent.PseudoTerminalRequest:
      log.debug("Client Pseudo Terminal event: \(context.remoteAddress?.description ?? "")")
      break
    case let event as SSHChannelRequestEvent.EnvironmentRequest:
      log.debug("Client Environment event: \(context.remoteAddress?.description ?? "")")
      break
    case let event as SSHChannelRequestEvent.ShellRequest:
      log.debug("Client shell event: \(context.remoteAddress?.description ?? "")")
      break
    case let event as SSHChannelRequestEvent.ExitSignal:
      log.debug("Client signal request event: \(context.remoteAddress?.description ?? "")")
      break
    case let event as SSHChannelRequestEvent.SignalRequest:
      log.debug("Client signal request event: \(context.remoteAddress?.description ?? "")")
      break
    case let event as SSHChannelRequestEvent.LocalFlowControlRequest:
      log.debug("Client local flow control request event: \(context.remoteAddress?.description ?? "")")
      break
    case let event as SSHChannelRequestEvent.WindowChangeRequest:
      log.debug("Client window change request event: \(context.remoteAddress?.description ?? "")")
      break
    case let event as SSHChannelRequestEvent.SubsystemRequest:
      log.debug("Client subsystem request event: \(context.remoteAddress?.description ?? "")")
      break
      default:
        log.debug("client event unsupported: \(context.remoteAddress?.description ?? "")")
    }
  }

  func channelActive(context: ChannelHandlerContext) {
    log.debug("Client active: \(context.remoteAddress?.description ?? "")")
  }

  func channelInactive(context: ChannelHandlerContext) {
    log.debug("Client inactive: \(context.remoteAddress?.description ?? "")")
  }

  func channelRegistered(context: ChannelHandlerContext) {
    log.debug("Client registered: \(context.remoteAddress?.description ?? "")")
  }

  func channelUnregistered(context: ChannelHandlerContext) {
    log.debug("Client unregistered: \(context.remoteAddress?.description ?? "")")
  }

  func channelReadComplete(context: ChannelHandlerContext) {
    log.debug("Client read complete: \(context.remoteAddress?.description ?? "")")
  }

  func channelWritabilityChanged(context: ChannelHandlerContext) {
    log.debug("Client write change: \(context.remoteAddress?.description ?? "")")
  }

  func channelRead(context: ChannelHandlerContext, data: NIOAny) {
    log.debug("Client read: \(context.remoteAddress?.description ?? "")")
    let asciiArt = """
      -------------
      < ASCII ART >
      -------------
      ^__^
      (oo)_______
      (__)       )
        ||----w |
        ||     ||
      """
    let buffer = context.channel.allocator.buffer(string: asciiArt)
    context.channel.writeAndFlush(SSHChannelData(type: .channel, data: .byteBuffer(buffer)), promise: nil)
    context.close(promise: nil)
    // let sshData = unwrapInboundIn(data)
    // if case .byteBuffer(let buffer) = sshData.data {
    //   let out = SSHChannelData(type: .channel, data: .byteBuffer(buffer))
    //   context.writeAndFlush(wrapOutboundOut(out), promise: nil)
    // }
  }
}

private final class ServerUserAuthDelegate: NIOSSHServerUserAuthenticationDelegate, Sendable {
  var supportedAuthenticationMethods: NIOSSH.NIOSSHAvailableUserAuthenticationMethods { .all }

  func requestReceived(
    request: NIOSSH.NIOSSHUserAuthenticationRequest,
    responsePromise: NIOCore.EventLoopPromise<NIOSSH.NIOSSHUserAuthenticationOutcome>
  ) {
    responsePromise.succeed(.success)
  }
}
