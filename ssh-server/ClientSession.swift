import Foundation
import Logging
import NIO
import NIOSSH
@_spi(Runners) import SwiftTUIRuntime
import SwiftTUITerminal
import Synchronization

final class ClientSession: Sendable {
  typealias AsyncChannel = NIOAsyncChannel<
    NIOSSHHandler.SSHChannelInboundData,
    NIOSSHHandler.SSHChannelOutboundData
  >

  private let outputStream: AsyncStream<[UInt8]>
  private let outputContinuation: AsyncStream<[UInt8]>.Continuation
  private let channel: AsyncChannel
  private let logger: Logger
  private let inputReader: SSHInputReader
  private let signalReader: InProcessSignalReader
  private let surface: SSHPresentationSurface

  private init(channel: AsyncChannel, logger: Logger) {
    let (outputStream, outputContinuation) = AsyncStream<[UInt8]>.makeStream()
    self.outputStream = outputStream
    self.outputContinuation = outputContinuation
    self.channel = channel
    self.logger = logger
    self.inputReader = SSHInputReader()
    self.signalReader = InProcessSignalReader()
    self.surface = SSHPresentationSurface(continuation: outputContinuation, logger: logger)
  }

  @MainActor
  private func start(pty: String, cellSize: CellSize) async throws {
    let logger = self.logger
    let app = WindowGroup {
      PortfolioView(logger: logger) { [weak self] in
        guard let self else {
          return
        }
        self.inputReader.finish()
        self.signalReader.finish()
        self.outputContinuation.finish()
      }
    }

    guard let primaryScene = collectWindowSceneSelections(from: app).first else {
      throw Error(.appInitializationFailed)
    }

    let resources = SceneSessionResources(
      presentationSurface: surface,
      terminalInputReader: inputReader,
      signalReader: signalReader,
      environmentValues: surface.environmentValues
    )

    surface.updateSurfaceSize(cellSize)
    surface.enableRawMode()
    defer { finish() }

    _ = try await primaryScene.run(
      sessionName: String(reflecting: "PortfolioApp"),
      resources: resources,
      stateContainer: StateContainer(
        initialState: SceneSessionState(),
        invalidationIdentities: [primaryScene.rootIdentity]
      ),
      focusTracker: FocusTracker(
        invalidationIdentities: [primaryScene.rootIdentity]
      )
    )
  }

  // Closes input/signal readers and the output stream. Does NOT write
  // terminal exit sequences — those are sent directly to outbound by
  // serve() so they can't be dropped by stream cancellation.
  private func finish() {
    inputReader.finish()
    signalReader.finish()
    outputContinuation.finish()
  }

  // The combined terminal-reset sequence, sent directly to outbound
  // by the output writer (on clean exit) or by the error handler.
  var exitSequence: String { surface.exitSequence }

  private func sendInput(_ bytes: [UInt8]) {
    inputReader.receive(bytes)
  }

  private func updateEnvironment(name: String, value: String) {
    surface.updateEnvironment(name: name, value: value)
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

        // Create the session before the do-catch so it's reachable in the
        // catch block where we need to send the terminal exit sequence.
        let session = ClientSession(channel: channel, logger: logger)

        do {
          try await withThrowingDiscardingTaskGroup { group in
            defer { group.cancelAll() }

            var hasReceivedPty = false
            var iterator = inbound.makeAsyncIterator()

            while let next = try await iterator.next() {
              switch next {
              case .data(let data):
                guard case .byteBuffer(let data) = data.data else { continue }
                logger.trace("Received new data event")
                session.sendInput(Array(buffer: data))

              case .event(.environment(let env)):
                session.updateEnvironment(name: env.name, value: env.value)

              case .event(.pseudoTerminal(let pty)):
                hasReceivedPty = true
                logger.trace(
                  "PTY request: TERM=\(pty.term), COLS=\(pty.terminalCharacterWidth), ROWS=\(pty.terminalRowHeight)",
                )

                group.addTask {
                  try await session.start(
                    pty: pty.term,
                    cellSize: CellSize(
                      width: pty.terminalCharacterWidth,
                      height: pty.terminalRowHeight
                    )
                  )
                }

                group.addTask {
                  // Drain all app output bytes first.
                  for await bytes in session.outputStream {
                    try await outbound.write(
                      .init(
                        type: .channel,
                        data: .byteBuffer(channel.channel.allocator.buffer(bytes: bytes))
                      )
                    )
                  }
                  // Stream is fully drained. Send the terminal exit sequence
                  // directly so it cannot be lost to task cancellation, then
                  // close the channel so the inbound iterator exits cleanly.
                  try await outbound.write(
                    .init(
                      type: .channel,
                      data: .byteBuffer(channel.channel.allocator.buffer(string: session.exitSequence))
                    )
                  )
                  channel.channel.close(promise: nil)
                }

              case .event(.windowChange(let wc)):
                session.onResize(
                  cellSize: CellSize(
                    width: wc.terminalCharacterWidth,
                    height: wc.terminalRowHeight
                  )
                )

              case .event(.channelFailure):
                throw Error(.unknown)

              case .event(.exec), .event(.shell):
                if !hasReceivedPty {
                  throw Error(.missingPseudoTerminalRequest)
                }

              default:
                logger.trace("Unhandled event in serve \(next)")
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
          // The output writer was cancelled before it could drain and send the
          // exit sequence. Send it directly here so the client exits alternate
          // screen before seeing the error message.
          let error = error as? Error ?? Error(.unknown, caught: error)
          if channel.channel.isActive, channel.channel.isWritable {
            if !error.errorDescription.isEmpty {
              try await outbound.write(
                .init(
                  type: .channel,
                  data: .byteBuffer(channel.channel.allocator.buffer(string: error.errorDescription))
                )
              )
            }
          }
          throw error
        }
      }
    } catch {
      logger.debug("\(error)")
    }
  }
}

// MARK: ClientSession + Error

extension ClientSession {
  struct Error: Swift.Error, CustomStringConvertible {
    var code: Code
    var caught: Swift.Error?

    init(_ code: Code, caught error: Swift.Error? = nil) {
      self.code = code
      self.caught = error
    }

    var description: String {
      "\(String(reflecting: code))\(caught.map { " Error: \($0)" } ?? "")"
    }

    var errorDescription: String { code.errorDescription }

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
}

// MARK: - SSHPresentationSurface

/// Bridges the SwiftTUI PresentationSurface protocol to SSH byte output.
private final class SSHPresentationSurface: PresentationSurfaceMetricsProvider, RasterPresentationSurface, Sendable {
  private struct State: Sendable {
    var surfaceSize: CellSize
    var capabilityProfile: TerminalCapabilityProfile
    var environmentValues: [String: String] = [:]
    var lastSurface: RasterSurface?
  }

  private let state: Mutex<State>
  private let writer: AsyncStream<[UInt8]>.Continuation
  private let logger: Logger

  init(continuation: AsyncStream<[UInt8]>.Continuation, logger: Logger) {
    self.logger = logger
    self.writer = continuation
    self.state = Mutex(
      State(
        surfaceSize: CellSize(width: 80, height: 24),
        capabilityProfile: .trueColor
      )
    )
  }

  var surfaceSize: CellSize { state.withLock(\.surfaceSize) }
  var capabilityProfile: TerminalCapabilityProfile { state.withLock(\.capabilityProfile) }
  var appearance: TerminalAppearance { .fallback }
  var environmentValues: [String: String] { state.withLock(\.environmentValues) }

  func updateSurfaceSize(_ size: CellSize) {
    state.withLock { $0.surfaceSize = size }
  }

  func updateEnvironment(name: String, value: String) {
    state.withLock { state in
      state.environmentValues[name] = value
      state.capabilityProfile = .detect(environment: state.environmentValues, isTTY: true)
    }
  }

  // MARK: Terminal setup / teardown

  func enableRawMode() {
    // Combine into one yield so it arrives atomically in the output stream.
    let setup =
      TerminalEscapeSequences.enterAlternateScreen
      + TerminalEscapeSequences.clearScreen
      + TerminalEscapeSequences.cursor(to: .zero)
      + TerminalEscapeSequences.hideCursor
    writer.yield(Array(setup.utf8))
    state.withLock { $0.lastSurface = nil }
  }

  var exitSequence: String {
    TerminalEscapeSequences.clearScreen
      + TerminalEscapeSequences.cursor(to: .zero)
      + TerminalEscapeSequences.resetStyle
      + TerminalEscapeSequences.showCursor
      + TerminalEscapeSequences.exitAlternateScreen
  }

  // MARK: RasterPresentationSurface

  func present(_ surface: RasterSurface) throws -> TerminalPresentationMetrics {
    let renderer = TerminalSurfaceRenderer(capabilityProfile: capabilityProfile)
    let lastSurface = state.withLock {
      let last = $0.lastSurface
      return last?.size == surface.size && last?.attachments == surface.attachments && last?.metadata == surface.metadata ? last : nil
    }

    var output = ""
    var linesTouched = 0
    var cellsChanged = 0

    if let lastSurface {
      let renderedRows = renderer.render(surface).components(separatedBy: "\r\n")
      let rowCount = max(
        max(lastSurface.cells.count, surface.cells.count),
        surface.size.height
      )

      for row in 0..<rowCount {
        let previousRow = row < lastSurface.cells.count ? lastSurface.cells[row] : []
        let currentRow = row < surface.cells.count ? surface.cells[row] : []
        guard previousRow != currentRow else { continue }

        linesTouched += 1
        let width = max(surface.size.width, max(previousRow.count, currentRow.count))
        for col in 0..<width {
          let prev = col < previousRow.count ? previousRow[col] : .empty
          let curr = col < currentRow.count ? currentRow[col] : .empty
          if prev != curr { cellsChanged += 1 }
        }

        let rowContent = row < renderedRows.count ? renderedRows[row] : ""
        output += TerminalEscapeSequences.cursor(to: CellPoint(x: 0, y: row))
        output += rowContent
        output += TerminalEscapeSequences.eraseToEndOfLine
      }
    } else {
      linesTouched = max(0, surface.size.height)
      cellsChanged = max(0, surface.size.width) * max(0, surface.size.height)

      let renderedRows = renderer.render(surface).components(separatedBy: "\r\n")
      output += TerminalEscapeSequences.clearScreen
      output += TerminalEscapeSequences.cursor(to: .zero)
      for (rowIndex, rowContent) in renderedRows.enumerated() where !rowContent.isEmpty {
        if rowIndex > 0 {
          output += TerminalEscapeSequences.cursor(to: CellPoint(x: 0, y: rowIndex))
        }
        output += rowContent
      }
    }

    let usedSynchronizedOutput = !output.isEmpty && lastSurface != nil && capabilityProfile.supportsSynchronizedOutput
    if usedSynchronizedOutput {
      output =
        TerminalEscapeSequences.beginSynchronizedOutput
        + output
        + TerminalEscapeSequences.endSynchronizedOutput
    }

    state.withLock { $0.lastSurface = surface }
    if !output.isEmpty {
      writer.yield(Array(output.utf8))
    }

    // logger.trace(
    //   "render",
    //    metadata: [
    //     "isIncremental": "\(lastSurface != nil)",
    //     "writtenBytes": "\(output.utf8.count)",
    //     "linesTouched": "\(linesTouched)",
    //     "cellsChanged": "\(cellsChanged)"
    //   ]
    // )

    return TerminalPresentationMetrics(
      bytesWritten: output.utf8.count,
      linesTouched: linesTouched,
      cellsChanged: cellsChanged,
      strategy: lastSurface == nil ? .fullRepaint : .incremental,
      usedSynchronizedOutput: usedSynchronizedOutput,
      graphicsReplayScope: .none,
      graphicsAttachmentsReplayed: 0,
      editOperationLowering: .none,
      editOperationCount: 0
    )
  }

  private enum TerminalEscapeSequences {
    static let clearScreen = "\u{001B}[2J"
    static let eraseToEndOfLine = "\u{001B}[K"
    static let beginSynchronizedOutput = "\u{001B}[?2026h"
    static let endSynchronizedOutput = "\u{001B}[?2026l"
    static let enterAlternateScreen = "\u{001B}[?1049h"
    static let exitAlternateScreen = "\u{001B}[?1049l"
    static let hideCursor = "\u{001B}[?25l"
    static let showCursor = "\u{001B}[?25h"
    static let resetStyle = "\u{001B}[0m"

    static func cursor(to point: CellPoint) -> String {
      "\u{001B}[\(max(1, point.y + 1));\(max(1, point.x + 1))H"
    }
  }
}
