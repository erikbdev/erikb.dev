import NIO
import NIOConcurrencyHelpers
import NIOSSH
@preconcurrency import SwiftTUI

private struct ClientState {
  let type: SSHChannelType

  var pty: SSHChannelRequestEvent.PseudoTerminalRequest?
  var hasPty: Bool { pty != nil }

  var application: Application?
}

final class InteractiveClient: ChannelDuplexHandler, @unchecked Sendable {
  init(type: SSHChannelType) {
    self._clientState = ClientState(type: type)
  }

  typealias InboundIn = SSHChannelData
  typealias InboundOut = SSHChannelData
  typealias OutboundIn = SSHChannelData
  typealias OutboundOut = SSHChannelData

  private let lock = NIOLock()
  private var _clientState: ClientState

  private var clientState: ClientState {
    get { lock.withLock { _clientState } }
    set { lock.withLock { _clientState = newValue } }
  }

  func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
    switch event {
    case let event as SSHChannelRequestEvent.PseudoTerminalRequest:
      // Asks for terminal, typically calls shell afterwards
      log.debug("Client Pseudo Terminal event: \(context.remoteAddress?.description ?? "")")
      clientState.pty = event
      break
    case let event as SSHChannelRequestEvent.ShellRequest:
      // request shell env
      // require pty for event
      log.debug("Client shell event: \(context.remoteAddress?.description ?? "")")
    case let event as SSHChannelRequestEvent.ExecRequest:
      // simulate argumet call
      // require pty to enable interaction for events
      log.debug("Client exec request event: \(context.remoteAddress?.description ?? "")")
    //   clientState.application = Application(rootView: CustomView()) { string in 
    //     context.write(NIOAny(string), promise: nil)
    //   }
    case let event as SSHChannelRequestEvent.WindowChangeRequest:
      // window size change
      log.debug("Client window change request event: \(context.remoteAddress?.description ?? "")")
      break
    case let event as SSHChannelRequestEvent.EnvironmentRequest:
      log.debug("Client Environment event: \(context.remoteAddress?.description ?? "")")
      break
    case let event as SSHChannelRequestEvent.ExitSignal:
      log.debug("Client signal request event: \(context.remoteAddress?.description ?? "")")
      context.channel.close(mode: .all, promise: nil)
      break
    case let event as SSHChannelRequestEvent.SignalRequest:
      log.debug("Client signal request event: \(context.remoteAddress?.description ?? "")")
      break
    case let event as SSHChannelRequestEvent.LocalFlowControlRequest:
      log.debug("Client local flow control request event: \(context.remoteAddress?.description ?? "")")
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
    context.fireChannelRead(data)
    // let asciiArt = """
    //   -------------
    //   < ASCII ART >
    //   -------------
    //   ^__^
    //   (oo)_______
    //   (__)       )
    //     ||----w |
    //     ||     ||
    //   """
    // let buffer = context.channel.allocator.buffer(string: asciiArt)
    // context.channel.writeAndFlush(SSHChannelData(type: .channel, data: .byteBuffer(buffer)), promise: nil)
    // context.close(promise: nil)
    // // let sshData = unwrapInboundIn(data)
    // if case .byteBuffer(let buffer) = sshData.data {
    //   let out = SSHChannelData(type: .channel, data: .byteBuffer(buffer))
    //   context.writeAndFlush(wrapOutboundOut(out), promise: nil)
    // }
  }
}

private struct CustomView: View {
  var body: some View {
    Text("Hello, Terminal!")
  }
}