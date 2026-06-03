import Foundation
import Logging
import NIO
import NIOSSH
import SwiftTUITerminal
@_spi(Runners) import SwiftTUIRuntime
import Synchronization

final class ClientSession: Sendable {
  struct Error: Swift.Error, CustomStringConvertible, LocalizedError {
    var code: Code
    var caught: Swift.Error?

    init(_ code: Code, caught error: Swift.Error? = nil) {
      self.code = code
      self.caught = error
    }

    var description: String {
      "\(String(reflecting: code))\(caught.map { " Error: \($0)" } ?? "")"
    }

    var errorDescription: String { code.localizedDescription }

    enum Code: Hashable, Sendable, LocalizedError {
      case missingPseudoTerminalRequest
      case connectionClosed(gracefully: Bool = false)
      case appInitializationFailed
      case unknown

      var errorDescription: String {
        switch self {
        case .missingPseudoTerminalRequest: "A pseudo terminal is required to access this application."
        case .connectionClosed(let gracefully): gracefully ? "" : "The connection unexpectedly closed."
        case .appInitializationFailed, .unknown: "An unknown error occurred."
        }
      }
    }
  }

  typealias AsyncChannel = NIOAsyncChannel<
    NIOSSHHandler.SSHChannelInboundData,
    NIOSSHHandler.SSHChannelOutboundData
  >

  // Bridges the SwiftTUI PresentationSurface protocol to SSH byte output.
  // Thread-safe: Mutex guards mutable state; AsyncStream.Continuation is Sendable.
  private final class SSHSurface: PresentationSurface, @unchecked Sendable {
    private struct State: Sendable {
      var surfaceSize: CellSize
      var capabilityProfile: TerminalCapabilityProfile
      var environment: [String: String] = [:]
    }

    private let state: Mutex<State>
    private let continuation: AsyncStream<[UInt8]>.Continuation

    init(continuation: AsyncStream<[UInt8]>.Continuation) {
      self.continuation = continuation
      state = Mutex(
        State(
          surfaceSize: CellSize(width: 80, height: 24),
          capabilityProfile: .trueColor
        )
      )
    }

    var surfaceSize: CellSize { state.withLock(\.surfaceSize) }
    var capabilityProfile: TerminalCapabilityProfile { state.withLock(\.capabilityProfile) }
    var appearance: TerminalAppearance { .fallback }

    func updateSurfaceSize(_ size: CellSize) {
      state.withLock { $0.surfaceSize = size }
    }

    func applyEnvironment(name: String, value: String) {
      state.withLock { state in
        state.environment[name] = value
        state.capabilityProfile = .detect(environment: state.environment, isTTY: true)
      }
    }

    // MARK: TerminalCommandPresentationSurface

    func enableRawMode() throws {
      // enter alternate screen, clear screen hide cursor
      try write("\u{001B}[?1049h\u{001B}[2J\u{001B}[?25l")
    }

    func disableRawMode() throws {
      // show raw cursor, reset styles, exit alternative scren
      try write("\u{1b}[?25h\u{1b}[?1049l")
    }

    func write(_ output: String) throws {
      continuation.yield(Array(output.utf8))
    }

    func clearScreen() throws {
      try write("\u{1b}[2J")
    }

    func moveCursor(to point: CellPoint) throws {
      try write("\u{1b}[\(point.y + 1);\(point.x + 1)H")
    }
  }

  nonisolated let outputStream: AsyncStream<[UInt8]>
  private nonisolated let outputContinuation: AsyncStream<[UInt8]>.Continuation
  private nonisolated let channel: AsyncChannel
  private nonisolated let logger: Logger
  private nonisolated let inputReader: SSHInputReader
  private nonisolated let signalReader: InProcessSignalReader
  private nonisolated let surface: SSHSurface

  private init(channel: AsyncChannel, logger: Logger) throws {
    let (outputStream, outputContinuation) = AsyncStream<[UInt8]>.makeStream()
    self.outputStream = outputStream
    self.outputContinuation = outputContinuation
    self.channel = channel
    self.logger = logger
    inputReader = SSHInputReader()
    signalReader = InProcessSignalReader()
    surface = SSHSurface(continuation: outputContinuation)
  }

  @MainActor
  private func start(pty: String, cellSize: CellSize) async throws {
    defer {
      inputReader.finish()
      signalReader.finish()
      outputContinuation.finish()
      channel.channel.close(mode: .input, promise: nil)
    }

    surface.updateSurfaceSize(cellSize)

    guard let selection = collectWindowSceneSelections(from: PortfolioApp().body).first else {
      throw Error(.appInitializationFailed)
    }

    let resources = SceneSessionResources(
      presentationSurface: surface,
      terminalInputReader: inputReader,
      signalReader: signalReader
    )

    _ = try await selection.run(
      sessionName: String(reflecting: PortfolioApp.self),
      resources: resources,
      stateContainer: StateContainer(
        initialState: SceneSessionState(),
        invalidationIdentities: [selection.rootIdentity]
      ),
      focusTracker: FocusTracker(
        invalidationIdentities: [selection.rootIdentity]
      )
    )
  }

  private func sendInput(_ bytes: [UInt8]) {
    inputReader.receive(bytes)
  }

  private func addEnvironment(name: String, value: String) {
    surface.applyEnvironment(name: name, value: value)
  }

  private func onResize(cellSize: CellSize) {
    surface.updateSurfaceSize(cellSize)
    signalReader.send("SIGWINCH")
  }

  static func serve(_ channel: AsyncChannel) async {
    let logger = {
      var logger = Logger(label: "\(Self.self)")
      logger[metadataKey: "ip"] = "\(channel.channel.remoteAddress?.ipAddress ?? "unknown")"
      return logger
    }()

    defer { logger.trace("Connection closed") }

    do {
      try await channel.executeThenClose { inbound, outbound in
        logger.debug("New connection")
        defer { logger.trace("Closing connection") }
        do {
          let session = try ClientSession(channel: channel, logger: logger)
          try await withThrowingDiscardingTaskGroup { group in
            defer { group.cancelAll() }

            var iterator = inbound.makeAsyncIterator()

            while let next = try await iterator.next() {
              switch next {
              case .data(let data):
                guard case .byteBuffer(let data) = data.data else { continue }
                session.sendInput(Array(buffer: data))

              case .event(.environment(let env)):
                session.addEnvironment(name: env.name, value: env.value)

              case .event(.pseudoTerminal(let pty)):
                logger.trace(
                  "PTY request",
                  metadata: [
                    "term": "\(pty.term)",
                    "cols": "\(pty.terminalCharacterWidth)",
                    "rows": "\(pty.terminalRowHeight)",
                  ]
                )

                group.addTask {
                  try await session.start(
                    pty: pty.term,
                    cellSize: CellSize(width: pty.terminalCharacterWidth, height: pty.terminalRowHeight)
                  )
                }

                group.addTask {
                  for await bytes in session.outputStream {
                    try await outbound.write(
                      .init(
                        type: .channel,
                        data: .byteBuffer(channel.channel.allocator.buffer(bytes: bytes))
                      )
                    )
                  }
                }

              case .event(.windowChange(let wc)):
                session.onResize(cellSize: CellSize(width: wc.terminalCharacterWidth, height: wc.terminalRowHeight))

              case .event(.channelFailure):
                throw Error(.unknown)

              default:
                continue
              }

              if next.wantReply {
                let reply = channel.channel.eventLoop.makePromise(of: Void.self)
                channel.channel.triggerUserOutboundEvent(ChannelSuccessEvent(), promise: reply)
                try await reply.futureResult.get()
              }
            }
          }
        } catch {
          let error = error as? Error ?? Error(.unknown, caught: error)
          if channel.channel.isActive, channel.channel.isWritable {
            try await outbound.write(
              .init(
                type: .channel,
                data: .byteBuffer(channel.channel.allocator.buffer(string: error.errorDescription))
              )
            )
          }
          throw error
        }
      }
    } catch {
      logger.debug("\(error)")
    }
  }
}
