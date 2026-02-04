import NIOSSH
import TauTUI

final class RemoteTerminal: Terminal {
  var columns: Int = 0
  var rows: Int = 0

  private var iterator: any AsyncIteratorProtocol<NIOSSHHandler.SSHChannelInboundData, Swift.Error>
  private var task: Task<Void, Error>?

  deinit {
    task?.cancel()
  }

  init(_ iterator: any AsyncIteratorProtocol<NIOSSHHandler.SSHChannelInboundData, Swift.Error>) {
    self.iterator = iterator
  }

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
