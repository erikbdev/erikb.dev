import NIOCore
import NIOSSH
import TauTUI

actor RemoteTerminal<Root: Container>: Sendable {
  typealias Writer = NIOAsyncChannelOutboundWriter<NIOSSHHandler.SSHChannelOutboundData>

  private var theme = ThemePalette.default
  private var pendingInputBuffer: ByteBuffer?
  private var previousLines: [String] = []
  private var previousWidth = 0
  private var cursorRaw = 0
  private var columns = 0
  private var rows = 0

  private let writer: Writer

  let root: Root

  init(
    _ root: Root,
    writer: Writer
  ) {
    self.root = root
    self.writer = writer
  }

  func render() async throws {

  }

  func parse(_ input: ByteBuffer) {
    self.pendingInputBuffer.setOrWriteImmutableBuffer(input)

    guard var pendingInputBuffer else {
      return
    }
    defer { self.pendingInputBuffer = pendingInputBuffer }

    var bufferedInputs: [TerminalInput] = []

    var escape = false

    repeat {
      var readableBytes = pendingInputBuffer.readableBytesView.makeIterator()

      switch (readableBytes.next(), escape) {
      case (0x1b, false):  // escape
        escape = true
      case (.none, true):
        bufferedInputs.append(.key(.escape))
      case (0x13, true):
        continue
      case (_, true):
        continue
      case (0x0D, _), (0x0A, _):
        bufferedInputs.append(.key(.enter))
      case (0x09, _):
        bufferedInputs.append(.key(.tab))
      case (0x7F, _), (0x08, _):
        bufferedInputs.append(.key(.backspace))
      case (.some(let byte), _):
        if byte < 0x20 {
          bufferedInputs.append(.key(.character(Character(Unicode.Scalar(byte + 0x60))), modifiers: .control))
        } else {
          bufferedInputs.append(.key(.character(Character(Unicode.Scalar(byte)))))
        }
      default:
        escape = false
        continue
      }
    } while pendingInputBuffer.readableBytes > 0

    for input in bufferedInputs {
      root.handle(input: input)
    }
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

  private func write(_ string: String) async throws {
    try await writer.write(.init(type: .channel, data: .byteBuffer(ByteBuffer(string: string))))
  }
}

extension ByteBuffer {
  fileprivate mutating func readByte() -> UInt8? {
    self.readInteger()
  }

  fileprivate func getByte() -> UInt8? {
    self.getInteger(at: self.readerIndex)
  }
}
