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
          try channel.pipeline.syncOperations.addHandler(_SSHRequestEventHandler())
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
    try self.addHandler(ParentChannelClosedListener(multiplexer))
    return multiplexer
  }
}

extension NIOSSHHandler {
  struct AsyncSSHMultiplexer<InboundChildOutput: Sendable>: Sendable {
    fileprivate let stream = AsyncStream.makeStream(of: InboundChildOutput.self)

    var inbound: AsyncStream<InboundChildOutput> { stream.stream }
  }

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
        return nil
      }
    }
  }
}

private final class _SSHRequestEventHandler: ChannelInboundHandler {
  typealias InboundIn = Any

  let (eventStream, eventContinuation) = AsyncStream.makeStream(of: NIOSSHHandler.RequestEvent.self)

  func channelInactive(context: ChannelHandlerContext) {
    eventContinuation.finish()
    context.fireChannelInactive()
  }

  func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
    if let event = NIOSSHHandler.RequestEvent(event) {
      eventContinuation.yield(event)
    }
    context.fireUserInboundEventTriggered(event)
  }
}

private final class ParentChannelClosedListener<Output: Sendable>: ChannelInboundHandler {
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

extension Channel {
  var requestEvents: EventLoopFuture<AsyncStream<NIOSSHHandler.RequestEvent>> {
    self.pipeline.handler(type: _SSHRequestEventHandler.self)
      .map(\.eventStream)
  }
}
