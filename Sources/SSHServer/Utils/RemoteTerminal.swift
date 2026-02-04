import NIOCore
import NIOSSH
import TauTUI

final class RemoteTerminal: Terminal, @unchecked Sendable {
  var columns: Int = 0
  var rows: Int = 0

  func start(
    onInput: @escaping (TerminalInput) -> Void,
    onResize: @escaping () -> Void
  ) throws {
  }

  func stop() {
  }

  func write(_ data: String) {
  }

  func moveBy(lines: Int) {

  }

  func hideCursor() {

  }

  func showCursor() {

  }

  func clearLine() {

  }

  func clearFromCursor() {

  }

  func clearScreen() {

  }

}

private struct InputProcessing {
  var buffer: ByteBuffer?
}