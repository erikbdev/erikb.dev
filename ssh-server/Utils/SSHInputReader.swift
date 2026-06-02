import NIOCore
@_spi(Runners) import SwiftTUIRuntime

// Bridges raw SSH byte input to SwiftTUI's TerminalInputReading protocol.
// TerminalInputParser (public SwiftTUIRuntime type) handles ANSI escape
// sequence parsing including arrows, Ctrl combinations, function keys, etc.
final class SSHInputReader: TerminalInputReading, @unchecked Sendable {
  let inputStream: AsyncStream<InputEvent>

  private let continuation: AsyncStream<InputEvent>.Continuation
  private var parser = TerminalInputParser()

  init() {
    let (stream, cont) = AsyncStream<InputEvent>.makeStream()
    inputStream = stream
    continuation = cont
  }

  func receive(_ bytes: [UInt8]) {
    let events = parser.feed(bytes)
    for event in events {
      continuation.yield(event)
    }
  }

  func inputEvents() -> AsyncStream<InputEvent> {
    inputStream
  }

  func finish() {
    continuation.finish()
  }
}
