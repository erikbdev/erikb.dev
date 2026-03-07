import Foundation
import NIOCore
import NIOSSH
import TauTUI

actor RemoteTerminal<Root: Component>: Sendable {
  typealias Writer = NIOAsyncChannelOutboundWriter<NIOSSHHandler.SSHChannelOutboundData>

  private var theme = ThemePalette.default
  private var pendingInputBuffer: ByteBuffer?
  private var previousLines: [String] = []
  private var previousWidth = 0
  private var cursorRow = 0
  private var columns = 0
  private var rows = 0
  private let writer: Writer
  private var capabilites: TerminalCapabilities
  private var environment = [String: String]()

  let root: Root 

  init(
    _ root: Root,
    writer: Writer,
    environment: [String: String] = [:],
    columns: Int = 80,
    rows: Int = 24
  ) {
    self.root = root
    self.writer = writer
    self.columns = columns
    self.rows = rows
    self.environment = environment 
    self.capabilites = TerminalImage.detectCapabilities(env: environment) 
  }

  /// Parser from: https://github.com/webpro/ANSI.tools/tree/main/packages/parser
  func parse(_ buffer: ByteBuffer) async throws {
    self.pendingInputBuffer.setOrWriteImmutableBuffer(buffer)

    guard var pendingInputBuffer else {
      return
    }

    defer { self.pendingInputBuffer = pendingInputBuffer }

    var bufferedInputs: [TerminalInput] = []

    outerLoop: while let byte = pendingInputBuffer.getByte() {
      switch (byte, pendingInputBuffer.getByte(offset: 1)) {
      case (0x1B, 0x4F):  // ESC O - SS3
        guard let third = pendingInputBuffer.getByte(offset: 2) else {
          break outerLoop  // incomplete, wait for more bytes
        }
        switch third {
        case 0x46: bufferedInputs.append(.key(.end))
        case 0x48: bufferedInputs.append(.key(.home))
        case 0x50: bufferedInputs.append(.key(.function(1)))
        case 0x51: bufferedInputs.append(.key(.function(2)))
        case 0x52: bufferedInputs.append(.key(.function(3)))
        case 0x53: bufferedInputs.append(.key(.function(4)))
        default:
          bufferedInputs.append(.key(.unknown(sequence: "\u{1B}O\(Character(Unicode.Scalar(third)))")))
        }
        pendingInputBuffer.moveReaderIndex(forwardBy: 3)
      case (0x1B, 0x50):  // (P) DCS
        continue
      case (0x1B, 0x5B):  // [ CSI
        var input: (TerminalKey, KeyModifiers) = (TerminalKey.unknown(sequence: ""), KeyModifiers())
        // switch pendingInputBuffer.getByte(offset: 2) {
        // case 0x01:
        //   input.0 = .home
        // // case 0x02:
        // //   input.0 = .insert
        // case 0x03:
        //   input.0 = .delete
        // case 0x04:
        //   input.0 = .end
        // // case 0x05:
        // //   input.0 = .pageUp
        // // case 0x06:
        // //   input.0 = .pageDown
        // case .some(let byte) where 0x0B <= byte && byte <= 0x0F:
        //   input.0 = .function(Int(byte - 0x0A))
        // case .some(let byte) where 0x11 <= byte && byte <= 0x15:
        //   input.0 = .function(Int(byte - 0x0B))
        // case .some(let byte) where 0x17 <= byte && byte <= 0x18:
        //   input.0 = .function(Int(byte - 0x0C))
        // case UInt8(ascii: "A"):
        //   input.0 = .arrowUp
        // case UInt8(ascii: "B"):
        //   input.0 = .arrowDown
        // case UInt8(ascii: "C"):
        //   input.0 = .arrowRight
        // case UInt8(ascii: "D"):
        //   input.0 = .arrowLeft
        // case UInt8(ascii: "H"):
        //   input.0 = .home
        // case UInt8(ascii: "F"):
        //   input.0 = .end
        // case UInt8(ascii: "A"):
        //   input.0 = .arrowUp
        // case UInt8(ascii: "Z"):
        //   input.0 = .tab
        //   input.1 = .shift

        // case .some(let byte):
        //   // TODO: Improve.
        //   input.0 = .unknown(sequence: String(Character(Unicode.Scalar(byte))))
        // case .none:
        //   // incomplete.
        //   break
        // }

        // switch pendingInputBuffer.getByte(offset: 3) {
        // case 0x3B:  // ;
        //   switch pendingInputBuffer.getByte(offset: 4) {
        //   case 0x02:
        //     input.1 = .shift
        //   case 0x03:
        //     input.1 = .option
        //   case 0x04:
        //     input.1 = [.shift, .option]
        //   case 0x05:
        //     input.1 = .control
        //   case 0x06:
        //     input.1 = [.shift, .control]
        //   case 0x07:
        //     input.1 = [.option, .control]
        //   case 0x08:
        //     input.1 = [.shift, .option, .control]
        //   case 0x09:
        //     input.1 = .meta
        //   case 0x0A:
        //     input.1 = [.shift, .meta]
        //   case 0x0B:
        //     input.1 = [.meta, .control]
        //   case 0x0C:
        //     input.1 = [.shift, .meta, .control]
        //   case .some:
        //     input.1 = []  // unknown modifier
        //   case .none:
        //     // missing bytes
        //     break
        //   }
        // case 0x7E:  // ~
        //   pendingInputBuffer.moveReaderIndex(to: 3)
        // case .none:
        //   break
        // }
        pendingInputBuffer.moveReaderIndex(forwardBy: 2)
        bufferedInputs.append(.key(input.0, modifiers: input.1))
      case (0x1B, 0x5D):  // ] OSC
        pendingInputBuffer.moveReaderIndex(forwardBy: 2)
      case (0x1B, 0x7F):  // ESC + DEL (Option+Backspace)
        bufferedInputs.append(.key(.backspace, modifiers: [.option]))
        pendingInputBuffer.moveReaderIndex(forwardBy: 2)
      case (0x1B, .some(let second)):  // ESC + ?
        // ESC + key is trated as option/meta on most terminals
        bufferedInputs.append(.key(.character(Character(Unicode.Scalar(second))), modifiers: [.option]))
        pendingInputBuffer.moveReaderIndex(forwardBy: 2)
      case (0x1B, .none):
        bufferedInputs.append(.key(.escape))
        pendingInputBuffer.moveReaderIndex(forwardBy: 1)
      case (0x0A, _), (0x0D, _):
        bufferedInputs.append(.key(.enter))
        pendingInputBuffer.moveReaderIndex(forwardBy: 1)
      case (0x09, _):
        bufferedInputs.append(.key(.tab))
        pendingInputBuffer.moveReaderIndex(forwardBy: 1)
      case (0x7F, _), (0x08, _):
        bufferedInputs.append(.key(.backspace))
        pendingInputBuffer.moveReaderIndex(forwardBy: 1)
      case (byte, _) where byte < 0x20:
        bufferedInputs.append(.key(.character(Character(Unicode.Scalar(byte + 0x60))), modifiers: .control))
        pendingInputBuffer.moveReaderIndex(forwardBy: 1)
      default:
        bufferedInputs.append(.key(.character(Character(Unicode.Scalar(byte)))))
        pendingInputBuffer.moveReaderIndex(forwardBy: 1)
      }
    }

    for input in bufferedInputs {
      root.handle(input: input)
    }
    
    try await self.performRender()
  }

  private func write(_ string: String) async throws {
    try await writer.write(.init(type: .channel, data: .byteBuffer(ByteBuffer(string: string))))
  }

  func addEnvironment(name: String, value: String) async throws {
    self.environment[name, default: ""] = value 
    let newCapabilities = TerminalImage.detectCapabilities(env: self.environment)
    guard newCapabilities.images != self.capabilites.images || 
          newCapabilities.trueColor != self.capabilites.trueColor || 
          newCapabilities.hyperlinks != self.capabilites.hyperlinks else {
      return
    }
    self.capabilites = newCapabilities
    try await performRender()
  }

  func resize(columns: Int, rows: Int) async throws {
    self.columns = columns
    self.rows = rows
    try await self.performRender()
  }

  private func queryCellSizeIfNeeded() async throws {
    guard self.capabilites.images != nil else { return }
    // Query terminal for cell size in pixels: CSI 16 t
    // Response format: CSI 6 ; height ; width t
    try await self.write("\u{001B}[16t")
  }

  // MARK: - Rendering

  func start() async throws {
    // clear buffer to the top of the screen
    // try await self.write("\u{001B}[?47h") // save screen)
    try await self.write("\u{001B}[?1049h") // switch to alternative screen
    try await self.write("\u{001B}[2J") // erase screen)
    try await self.write("\u{001B}[H") // move cursor to top of the scren.
    try await self.write("\u{001B}[?25l") // hide cursor
    try await self.queryCellSizeIfNeeded()
    try await self.performRender()
  }

  private func performRender() async throws {
    let width = self.columns
    let height = self.rows
    let newLines = render(width: width)

    guard !newLines.isEmpty else {
      self.previousLines = []
      self.previousWidth = width
      self.cursorRow = 0
      return
    }

    if self.previousLines.isEmpty {
      try await self.writeFullRender(newLines)
      self.previousLines = newLines
      self.previousWidth = width
      self.cursorRow = newLines.count - 1
      return
    }

    if self.previousWidth != width {
      try await self.writeFullRender(newLines, clear: true)
      self.previousLines = newLines
      self.previousWidth = width
      self.cursorRow = newLines.count - 1
      return
    }

    guard let diffRange = computeDiffRange(old: previousLines, new: newLines) else {
      return  // no changes
    }

    let viewportTop = self.cursorRow - height + 1
    if diffRange.lowerBound < viewportTop {
      try await self.writeFullRender(newLines, clear: true)
      self.previousLines = newLines
      self.previousWidth = width
      self.cursorRow = newLines.count - 1
      return
    }

    try await self.writePartialRender(lines: newLines, from: diffRange.lowerBound)
    self.previousLines = newLines
    self.previousWidth = width
    self.cursorRow = newLines.count - 1
  }

  private func computeDiffRange(old: [String], new: [String]) -> Range<Int>? {
    let maxCount = max(old.count, new.count)
    var firstChanged: Int?
    var lastChanged: Int?

    for index in 0..<maxCount {
      let oldLine = index < old.count ? old[index] : ""
      let newLine = index < new.count ? new[index] : ""
      if oldLine != newLine {
        if firstChanged == nil { firstChanged = index }
        lastChanged = index
      }
    }

    guard let start = firstChanged, let end = lastChanged else {
      return nil
    }
    return start..<(end + 1)
  }

  private func writeFullRender(_ lines: [String], clear: Bool = false) async throws {
    var buffer = ANSI.syncStart
    if clear {
      buffer += ANSI.clearScrollbackAndScreen
    }
    buffer += lines.joined(separator: "\r\n")
    buffer += ANSI.syncEnd
    try await self.write(buffer)
  }

  private func writePartialRender(lines: [String], from start: Int) async throws {
    var buffer = ANSI.syncStart
    let lineDiff = start - self.cursorRow
    if lineDiff > 0 {
      buffer += ANSI.cursorDown(lineDiff)
    } else if lineDiff < 0 {
      buffer += ANSI.cursorUp(-lineDiff)
    }

    buffer += ANSI.carriageReturn

    for index in start..<lines.count {
      if index > start { buffer += "\r\n" }
      let line = lines[index]
      if !self.containsImage(line) {
        precondition(VisibleWidth.measure(line) <= self.columns, "Rendered line exceeds width")
      }
      buffer += ANSI.clearLine
      buffer += line
    }

    if self.previousLines.count > lines.count {
      let extraLines = self.previousLines.count - lines.count
      for _ in 0..<extraLines {
        buffer += "\r\n" + ANSI.clearLine
      }
      buffer += ANSI.cursorUp(extraLines)
    }

    buffer += ANSI.syncEnd
    try await self.write(buffer)
  }

  private func containsImage(_ line: String) -> Bool {
    line.contains("\u{001B}_G") || line.contains("\u{001B}]1337;File=")
  }

  private func render(width: Int) -> [String] {
    root.render(width: width)
  }
}

extension ByteBuffer {
  fileprivate mutating func readByte() -> UInt8? {
    self.readInteger()
  }

  fileprivate func getByte(offset: Int = 0) -> UInt8? {
    self.getInteger(at: self.readerIndex + offset)
  }
}