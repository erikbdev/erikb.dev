import NIOCore
@_spi(Runners) import SwiftTUIRuntime
import Synchronization

// Bridges SwiftTUI's SemanticHostFramePresentationSurface to an SSH outbound channel.
// Renders each committed frame to ANSI bytes and yields them to outputStream for
// async forwarding to the SSH client.
final class SSHPresentationSurface: SemanticHostFramePresentationSurface, Sendable {
  private struct State: Sendable {
    var surfaceSize: CellSize
    var environment: [String: String]
    var isFirstFrame = true

    var capabilityProfile: TerminalCapabilityProfile {
      .detect(environment: environment, isTTY: true)
    }
  }

  let outputStream: AsyncStream<ByteBuffer>
  private let state: Mutex<State>
  private let continuation: AsyncStream<ByteBuffer>.Continuation

  init(columns: Int, rows: Int, environment: [String: String] = [:]) {
    let (stream, cont) = AsyncStream<ByteBuffer>.makeStream()
    outputStream = stream
    continuation = cont
    state = Mutex(
      State(surfaceSize: CellSize(width: columns, height: rows), environment: environment)
    )
  }

  var surfaceSize: CellSize {
    state.withLock(\.surfaceSize)
  }

  var capabilityProfile: TerminalCapabilityProfile {
    state.withLock(\.capabilityProfile)
  }

  // SSH connections cannot probe terminal color scheme; fall back to the default.
  var appearance: TerminalAppearance { .fallback }

  var theme: Theme? { nil }

  var graphicsCapabilities: TerminalGraphicsCapabilities { .none }

  var pointerInputCapabilities: PointerInputCapabilities { .cellOnly }

  @discardableResult
  func present(_ frame: SemanticHostFrame) throws -> PresentationMetrics {
    let (profile, isFirstFrame) = state.withLock { state in
      let profile = state.capabilityProfile
      let first = state.isFirstFrame
      state.isFirstFrame = false
      return (profile, first)
    }

    let surface = frame.raster
    let renderer = TerminalSurfaceRenderer(capabilityProfile: profile)
    var output = ""

    let needsFullRepaint =
      isFirstFrame
      || frame.rasterDamage == nil
      || frame.rasterDamage!.requiresFullTextRepaint

    let strategy: PresentationMetrics.Strategy
    let linesTouched: Int

    if needsFullRepaint {
      strategy = .fullRepaint
      linesTouched = surface.size.height

      if isFirstFrame {
        output += "\u{001B}[?1049h"  // enter alternate screen
        output += "\u{001B}[?25l"    // hide cursor
      }
      output += "\u{001B}[2J"  // clear screen
      output += "\u{001B}[H"   // cursor home
      output += renderer.render(surface)
    } else {
      let damage = frame.rasterDamage!
      strategy = .incremental
      let dirtyRows = damage.dirtyRows.sorted()
      linesTouched = dirtyRows.count

      if !dirtyRows.isEmpty {
        // Split the full render into per-row strings, then emit only dirty rows
        // with cursor positioning. The separator matches TerminalSurfaceRenderer.render(_:).
        let allRows = renderer.render(surface).split(
          separator: "\r\n",
          omittingEmptySubsequences: false
        )
        for row in dirtyRows {
          output += "\u{001B}[\(row + 1);1H"  // cursor to row (1-indexed), col 1
          if row < allRows.count {
            output += allRows[row]
          }
          output += "\u{001B}[K"  // erase remainder of line
        }
      }
    }

    if profile.supportsSynchronizedOutput, !output.isEmpty {
      output = "\u{001B}[?2026h" + output + "\u{001B}[?2026l"
    }

    if !output.isEmpty {
      continuation.yield(ByteBuffer(string: output))
    }

    let bytesWritten = output.utf8.count
    let cellsChanged =
      strategy == .fullRepaint
      ? max(0, surface.size.width) * max(0, surface.size.height)
      : linesTouched * max(0, surface.size.width)

    return PresentationMetrics(
      bytesWritten: bytesWritten,
      linesTouched: linesTouched,
      cellsChanged: cellsChanged,
      strategy: strategy,
      usedSynchronizedOutput: profile.supportsSynchronizedOutput && !output.isEmpty
    )
  }

  func addEnvironment(name: String, value: String) {
    state.withLock { $0.environment[name] = value }
  }

  func resize(columns: Int, rows: Int) {
    state.withLock { $0.surfaceSize = CellSize(width: columns, height: rows) }
  }

  func finish() {
    // Restore cursor and exit alternate screen before closing the stream.
    continuation.yield(ByteBuffer(string: "\u{001B}[?25h\u{001B}[?1049l"))
    continuation.finish()
  }
}
