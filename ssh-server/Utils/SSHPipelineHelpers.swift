import NIOCore
@preconcurrency import NIOSSH

extension Channel {
  func configureSSHPipeline<Output: Sendable>(
    role: SSHConnectionRole,
    allocator: ByteBufferAllocator? = nil,
    inboundChildChannelInitializer: @escaping ((Channel, SSHChannelType) -> EventLoopFuture<Output>)
  ) -> EventLoopFuture<(Channel, NIOSSHHandler.AsyncSSHMultiplexer<Output>)> {
    if self.eventLoop.inEventLoop {
      self.eventLoop.makeCompletedFuture {
        try self.pipeline.syncOperations.configureSSHPipeline(
          role: role,
          allocator: allocator ?? self.allocator,
          inboundChildChannelInitializer: inboundChildChannelInitializer
        )
      }
      .map { (self, $0) }
    } else {
      self.eventLoop.submit {
        try self.pipeline.syncOperations.configureSSHPipeline(
          role: role,
          allocator: allocator ?? self.allocator,
          inboundChildChannelInitializer: inboundChildChannelInitializer
        )
      }
      .map { (self, $0) }
    }
  }
}

extension ChannelPipeline.SynchronousOperations {
  func configureSSHPipeline<Output: Sendable>(
    role: SSHConnectionRole,
    allocator: ByteBufferAllocator,
    inboundChildChannelInitializer: @escaping ((Channel, SSHChannelType) -> EventLoopFuture<Output>)
  ) throws -> NIOSSHHandler.AsyncSSHMultiplexer<Output> {
    let multiplexer = NIOSSHHandler.AsyncSSHMultiplexer<Output>()
    let handler = NIOSSHHandler(
      role: role,
      allocator: allocator,
      inboundChildChannelInitializer: { channel, kind in
        channel.eventLoop.makeCompletedFuture {
          try channel.pipeline.syncOperations.addHandler(SSHMergeEventAndDataHandler())
        }
        .flatMap {
          inboundChildChannelInitializer(channel, kind)
            .flatMap { output in
              channel.eventLoop.makeCompletedFuture {
                multiplexer.stream.continuation.yield(output)
              }
            }
        }
      }
    )
    try self.addHandler(handler)
    try self.addHandler(_ParentChannelClosedListener(multiplexer))
    return multiplexer
  }
}

extension NIOSSHHandler {
  struct AsyncSSHMultiplexer<InboundChildOutput: Sendable>: Sendable {
    fileprivate let stream = AsyncStream.makeStream(of: InboundChildOutput.self)

    var inbound: AsyncStream<InboundChildOutput> { stream.stream }
  }

  enum SSHChannelInboundData {
    case event(RequestEvent)
    case data(SSHChannelData)

    var wantReply: Bool {
      switch self {
      case .event(let e):
        return e.wantReply
      case .data:
        return false
      }
    }
  }

  typealias SSHChannelOutboundData = SSHChannelData

  enum RequestEvent {
    case pseudoTerminal(SSHChannelRequestEvent.PseudoTerminalRequest)
    case environment(SSHChannelRequestEvent.EnvironmentRequest)
    case shell(SSHChannelRequestEvent.ShellRequest)
    case exec(SSHChannelRequestEvent.ExecRequest)
    case exitStatus(SSHChannelRequestEvent.ExitStatus)
    case exitSignal(SSHChannelRequestEvent.ExitSignal)
    case subsystem(SSHChannelRequestEvent.SubsystemRequest)
    case windowChange(SSHChannelRequestEvent.WindowChangeRequest)
    case localFlowControl(SSHChannelRequestEvent.LocalFlowControlRequest)
    case signal(SSHChannelRequestEvent.SignalRequest)
    case channelSuccess
    case channelFailure

    var wantReply: Bool {
      switch self {
      case .pseudoTerminal(let e):
        return e.wantReply
      case .channelFailure, .channelSuccess:
        return false
      case .environment(let e):
        return e.wantReply
      case .shell(let e):
        return e.wantReply
      case .exec(let e):
        return e.wantReply
      case .exitStatus(let e):
        return e.wantReply
      case .exitSignal(let e):
        return e.wantReply
      case .subsystem(let e):
        return e.wantReply
      case .windowChange(let e):
        return e.wantReply
      case .localFlowControl(let e):
        return e.wantReply
      case .signal(let e):
        return e.wantReply
      }
    }

    fileprivate init?(_ value: Any) {
      switch value {
      case let event as SSHChannelRequestEvent.PseudoTerminalRequest:
        self = .pseudoTerminal(event)
      case let event as SSHChannelRequestEvent.EnvironmentRequest:
        self = .environment(event)
      case let event as SSHChannelRequestEvent.ShellRequest:
        self = .shell(event)
      case let event as SSHChannelRequestEvent.ExecRequest:
        self = .exec(event)
      case let event as SSHChannelRequestEvent.ExitStatus:
        self = .exitStatus(event)
      case let event as SSHChannelRequestEvent.ExitSignal:
        self = .exitSignal(event)
      case let event as SSHChannelRequestEvent.SubsystemRequest:
        self = .subsystem(event)
      case let event as SSHChannelRequestEvent.WindowChangeRequest:
        self = .windowChange(event)
      case let event as SSHChannelRequestEvent.LocalFlowControlRequest:
        self = .localFlowControl(event)
      case let event as SSHChannelRequestEvent.SignalRequest:
        self = .signal(event)
      case _ where value is ChannelSuccessEvent:
        self = .channelSuccess
      case _ where value is ChannelFailureEvent:
        self = .channelFailure
      default:
        logger.trace("Unhandled request event: \(value)")
        return nil
      }
    }
  }
}

private final class SSHMergeEventAndDataHandler: ChannelInboundHandler {
  typealias InboundIn = SSHChannelData
  typealias InboundOut = NIOSSHHandler.SSHChannelInboundData

  func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
    if let event = NIOSSHHandler.RequestEvent(event) {
      context.fireChannelRead(self.wrapInboundOut(.event(event)))
      context.fireChannelReadComplete()
    }
    context.fireUserInboundEventTriggered(event)
  }

  func channelRead(context: ChannelHandlerContext, data: NIOAny) {
    context.fireChannelRead(self.wrapInboundOut(.data(self.unwrapInboundIn(data))))
  }

  func channelInactive(context: ChannelHandlerContext) {
    context.fireChannelInactive()
  }
}

private final class _ParentChannelClosedListener<Output: Sendable>: ChannelInboundHandler {
  typealias InboundIn = Any

  let multiplexer: NIOSSHHandler.AsyncSSHMultiplexer<Output>

  init(_ multiplexer: NIOSSHHandler.AsyncSSHMultiplexer<Output>) {
    self.multiplexer = multiplexer
  }

  func channelInactive(context: ChannelHandlerContext) {
    multiplexer.stream.continuation.finish()
    context.fireChannelInactive()
  }
}
