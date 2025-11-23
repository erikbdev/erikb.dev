import ArgumentParser
@preconcurrency import NIO
@preconcurrency import NIOSSH

@main
struct Terminal: AsyncParsableCommand {
  @Option(name: .shortAndLong)
  var host = "0.0.0.0"

  @Option(name: .shortAndLong)
  var port = 2222

  func run() async throws {
    let delegate = ServerUserAuthDelegate()
    let hostKey = NIOSSHPrivateKey(ed25519Key: .init())
    let eventLoop = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    let bootstrap = ServerBootstrap(group: eventLoop)
      .serverChannelOption(ChannelOptions.backlog, value: 256)
      .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
      .childChannelInitializer { channel in
        channel.pipeline.addHandler(
          NIOSSHHandler(
            role: .server(
              SSHServerConfiguration(
                hostKeys: [hostKey],
                userAuthDelegate: delegate,
                globalRequestDelegate: nil,
                banner: nil,
                transportProtectionSchemes: []
              )
            ),
            allocator: channel.allocator,
          ) { child, type in
            if type == .session {
              child.close()
            } else {
              child.pipeline.addHandler(EchoSessionHandler())
            }
          }
        )
      }

    do {
      let serverChannel =
        try await bootstrap
        .bind(host: host, port: port)
        .get()

      print("SSH server listening on \(String(describing: serverChannel.localAddress))")
      try await serverChannel.closeFuture.get()
    } catch {
      print("Failed to start SSH server", error)
    }

    do {
      try await eventLoop.shutdownGracefully()
    } catch {
      print("Shutdown failed: \(error)")
    }
  }
}

private final class EchoSessionHandler: ChannelDuplexHandler, Sendable {
  typealias InboundIn = SSHChannelData
  typealias OutboundIn = SSHChannelData
  typealias OutboundOut = SSHChannelData

  func channelRead(context: ChannelHandlerContext, data: NIOAny) {
    // let sshData = unwrapInboundIn(data)
    // if case .byteBuffer(let buffer) = sshData.data {
      // let out = SSHChannelData(type: .channel, data: .byteBuffer(buffer))
      // context.writeAndFlush(wrapOutboundOut(out), promise: nil)
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
