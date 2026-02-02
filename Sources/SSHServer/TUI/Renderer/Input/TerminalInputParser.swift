// Copyright © 2025 Saleem Abdulrasool <compnerd@compnerd.org>
// SPDX-License-Identifier: BSD-3-Clause

import NIOCore

/// Standard virtual key codes for terminal input.
///
/// `VTKeyCode` provides constants for common virtual key codes used in
/// terminal applications. These codes represent special keys that don't
/// generate printable characters, such as arrow keys, function keys,
/// and control keys.
///
/// The key codes follow standard virtual key conventions and can be used
/// to identify specific key presses in `KeyEvent` objects.
///
/// ## Usage Example
/// ```swift
/// func handleKeyEvent(_ event: KeyEvent) {
///   switch event.keycode {
///   case VTKeyCode.escape:
///     exitApplication()
///   case VTKeyCode.F1:
///     showHelp()
///   case VTKeyCode.up:
///     moveCursorUp()
///   default:
///     if let char = event.character {
///       insertText(char)
///     }
///   }
/// }
/// ```
public struct KeyCode: Hashable, Sendable {
  let rawValue: UInt16

  fileprivate init(_ rawValue: UInt16) {
    self.rawValue = rawValue
  }

  public static var escape: Self { Self(0x1b) }
  public static var left: Self { Self(0x25) }
  public static var up: Self { Self(0x26) }
  public static var right: Self { Self(0x27) }
  public static var down: Self { Self(0x28) }
  public static var F1: Self { Self(0x70) }
  public static var F2: Self { Self(0x71) }
  public static var F3: Self { Self(0x72) }
  public static var F4: Self { Self(0x73) }
  public static var F5: Self { Self(0x74) }
  public static var F6: Self { Self(0x75) }
  public static var F7: Self { Self(0x76) }
  public static var F8: Self { Self(0x77) }
  public static var F9: Self { Self(0x78) }
  public static var F10: Self { Self(0x79) }
  public static var F11: Self { Self(0x7a) }
  public static var F12: Self { Self(0x7b) }
  public static var F13: Self { Self(0x7c) }
  public static var F14: Self { Self(0x7d) }

  fileprivate static var zero: Self { Self(0) }
}

/// Cursor movement directions for terminal input parsing.
///
/// Used internally by the input parser to represent directional movement
/// commands from arrow keys and other navigation sequences.
enum Direction {
  case up
  case down
  case left
  case right
}

/// Represents different types of parsed terminal input sequences.
///
/// Terminal input consists of various sequence types, from simple characters
/// to complex escape sequences. This enum captures the different categories
/// of input that the parser can recognize and extract meaning from.
///
/// The parser handles:
/// - Regular printable characters
/// - Cursor movement sequences (arrow keys)
/// - Function key sequences
/// - Unknown or malformed sequences
enum ParsedSequence {
  case character(Character)
  case cursor(direction: Direction, count: Int)
  case function(number: Int, modifiers: KeyModifiers)
  case unknown(sequence: [UInt8])
}

/// A state machine parser for terminal input sequences.
///
/// `VTInputParser` implements a robust parser for terminal input that handles
/// the complexity of ANSI escape sequences, control sequences, and Unicode
/// text. The parser operates as a state machine that can process partial
/// input and request more data when needed.
///
/// ## Key Features
///
/// - **Incremental parsing**: Handles partial input streams gracefully
/// - **State preservation**: Maintains parse state across multiple calls
/// - **Error recovery**: Continues parsing after encountering malformed input
/// - **Unicode support**: Properly handles multi-byte character sequences
/// - **ANSI compatibility**: Supports standard terminal escape sequences
///
/// ## Usage Pattern
///
/// The parser is designed to be fed raw terminal input incrementally:
///
/// ```swift
/// var parser = VTInputParser()
/// let sequences = parser.parse(&buffer)
///
/// for sequence in sequences {
///   if let event = sequence.event {
///     handleKeyEvent(event)
///   }
/// }
/// ```
///
/// ## Error Handling
///
/// The parser is designed to be resilient to malformed input. When it
/// encounters invalid sequences, it drops the problematic bytes and
/// continues parsing the rest of the input stream.
struct TerminalInputParser {
  private enum State {
    /// Normal text parsing mode - looking for regular characters or escape.
    case normal
    /// Just received an escape character - determining sequence type.
    case escape
    /// Parsing a Control Sequence Introducer (CSI) sequence.
    case CSI(parameters: [Int], intermediate: [UInt8])
    /// Parsing an Operating System Command (OSC) sequence.
    case OSC(data: [UInt8])
    /// Parsing a Device Control String (DCS) sequence.
    case DCS(data: [UInt8])
    /// Parsing a Single Shift Three (SS3) sequence.
    case SS3
  }

  private enum ParseResult {
    case success(_ result: KeyEvent, _ nextState: State)
    case failure(_ nextState: State)
    case indeterminate(_ nextState: State)
  }

  private var state = State.normal
  private var buffer: ByteBuffer?

  /// Parses a byte array into a sequence of recognized terminal input events.
  ///
  /// This is the main entry point for parsing terminal input. It processes
  /// the input incrementally, maintaining state between calls to handle
  /// incomplete escape sequences that span multiple input buffers.
  ///
  /// The parser is resilient to malformed input - when it encounters invalid
  /// sequences, it drops the problematic bytes and continues processing.
  internal mutating func parse(_ input: ByteBuffer) -> [KeyEvent] {
    var results: [KeyEvent] = []

    self.buffer.setOrWriteImmutableBuffer(input)

    guard var buffer else {
      return results
    }

    while buffer.readableBytes > 0 {
      let parseResult =
        switch state {
        case .normal:
          Self.parse(normal: &buffer)
        case .escape:
          Self.parse(escape: &buffer)
        case .CSI(let parameters, let intermediate):
          Self.parse(csi: &buffer, parameters: parameters, intermediate: intermediate)
        case .OSC(let data):
          Self.parse(osc: &buffer, data: data)
        case .DCS(let data):
          Self.parse(dcs: &buffer, data: data)
        case .SS3:
          Self.parse(ss3: &buffer)
        }

      switch parseResult {
      case .success(let sequence, let state):
        results.append(sequence)
        self.state = state
        self.buffer = buffer
      case .failure(let state):
        // drop invalid byte and continue
        buffer.moveReaderIndex(forwardBy: 1)
        self.state = state
        self.buffer = buffer
      case .indeterminate(let state):
        self.state = state
        self.buffer = buffer
      }
    }

    return results
  }
}

extension TerminalInputParser {
  private static func parse(normal input: inout ByteBuffer) -> ParseResult {
    guard let byte = input.readByte() else { return .indeterminate(.normal) }

    if byte == 0x1b {  // escape
      return parse(escape: &input)
    }

    let scalar = UnicodeScalar(byte)
    if scalar.isASCII {
      return .success(KeyEvent(scalar: scalar, keycode: .zero), .normal)
    }

    // UTF-8 multibyte sequence
    return .failure(.normal)
  }

  private static func parse(escape input: inout ByteBuffer) -> ParseResult {
    guard let byte = input.getByte() else {
      return .success(KeyEvent(character: "\u{1b}", keycode: .escape), .normal)
    }

    switch byte {
    case 0x4f:  // O (SS3)
      input.moveReaderIndex(forwardBy: 1)
      return parse(ss3: &input)

    case 0x50:  // P (DCS)
      input.moveReaderIndex(forwardBy: 1)
      return parse(dcs: &input, data: [])

    case 0x5b:  // [ (CSI)
      input.moveReaderIndex(forwardBy: 1)
      return parse(csi: &input, parameters: [], intermediate: [])

    case 0x5d:  // ] (OSC)
      input.moveReaderIndex(forwardBy: 1)
      return parse(osc: &input, data: [])

    default:
      // invalid escape sequence
      return .failure(.normal)
    }
  }

  private static func parse(
    csi input: inout ByteBuffer,
    parameters: [Int],
    intermediate: [UInt8]
  ) -> ParseResult {
    guard let byte = input.getByte() else {
      return .indeterminate(.CSI(parameters: parameters, intermediate: intermediate))
    }
    switch byte {
    case 0x20...0x2f:  // intermediate bytes
      input.moveReaderIndex(forwardBy: 1)
      return parse(csi: &input, parameters: parameters, intermediate: intermediate + [byte])

    case 0x30...0x39:  // '0'-'9' (Pn...Ps)
      let parameters = parse(parameters: &input, parsed: parameters)
      return parse(csi: &input, parameters: parameters, intermediate: intermediate)

    case 0x3b:  // ';' (Parameter Separator)
      input.moveReaderIndex(forwardBy: 1)
      return parse(csi: &input, parameters: parameters, intermediate: intermediate)

    case 0x40...0x7e:  // command
      input.moveReaderIndex(forwardBy: 1)
      return .success(
        parse(csi: byte, parameters: parameters, intermediate: intermediate),
        .normal
      )

    default:
      // invalid CSI sequence
      input.moveReaderIndex(forwardBy: 1)
      return .failure(.normal)
    }
  }

  private static func parse(ss3 input: inout ByteBuffer) -> ParseResult {
    guard let byte = input.readByte() else { return .indeterminate(.SS3) }

    return switch byte {
    case 0x41:  // 'A'
      .success(KeyEvent(keycode: .up), .normal)
    case 0x42:  // 'B'
      .success(KeyEvent(keycode: .down), .normal)
    case 0x43:  // 'C'
      .success(KeyEvent(keycode: .right), .normal)
    case 0x44:  // 'D'
      .success(KeyEvent(keycode: .left), .normal)
    default:
      .failure(.normal)
    }
  }

  private static func parse(osc input: inout ByteBuffer, data: [UInt8]) -> ParseResult {
    guard let byte = input.readByte() else { return .indeterminate(.OSC(data: data)) }

    if byte == 0x07 /* bell */ {
      //   return .success(
      //     .unknown(sequence: [0x1b, 0x5d] + data + [byte]),
      //     .normal
      //   )
      return .failure(.normal)
    } else if byte == 0x1b /* escape */ {
      // Check for ESC \ terminator
      guard input.getByte() == 0x5c else {
        return .failure(.OSC(data: data))
      }
      return .failure(.normal)
    //   return .success(
    //     .unknown(sequence: [0x1b, 0x5d] + data + [byte]),
    //     .normal
    //   )
    }

    return parse(osc: &input, data: data + [byte])
  }

  private static func parse(dcs input: inout ByteBuffer, data: [UInt8]) -> ParseResult {
    guard let byte = input.getByte() else { return .indeterminate(.DCS(data: data)) }
    if byte == 0x1b /* escape */ {
      // Check for ESC \ terminator
      guard input.getInteger(at: input.readerIndex + 1, as: UInt8.self) == 0x5c else {
        return .indeterminate(.DCS(data: data))
      }
      input.moveReaderIndex(forwardBy: 2)
      return .failure(.normal)
      // return .success(.unknown(sequence: [0x1b, 0x50] + data), .normal)
    }
    input.moveReaderIndex(to: 1)
    return parse(dcs: &input, data: data + [byte])
  }
}

extension TerminalInputParser {
  private static func parse(parameters input: inout ByteBuffer, parsed parameters: [Int]) -> [Int] {
    var parameters = parameters
    var parameter = ""

    while let byte = input.getByte(), (0x30...0x39).contains(byte) {
      parameter.append(Character(UnicodeScalar(byte)))
      input.moveReaderIndex(forwardBy: 1)
    }

    if !parameter.isEmpty {
      parameters.append(Int(parameter) ?? 0)
    }

    return parameters
  }

  private static func parse(csi command: UInt8, parameters: [Int], intermediate: [UInt8]) -> KeyEvent {
    let count = parameters.first ?? 1
    switch command {
    case 0x41:  // 'A' (CUU)
      return KeyEvent(keycode: .up)
    // return .cursor(direction: .up, count: count)
    case 0x42:  // 'B' (CUD)
      return KeyEvent(keycode: .down)
    case 0x43:  // 'C' (CUF)
      return KeyEvent(keycode: .right)
    case 0x44:  // 'D' (CUB)
      return KeyEvent(keycode: .left)
    default:
      let sequence: [UInt8] = [UInt8(0x1b), UInt8(0x5b)] + parameters.flatMap { String($0).utf8 } + [UInt8(0x3b)] + intermediate + [command]
      return KeyEvent(character: nil, keycode: .zero)
    }
  }
}

extension ParsedSequence {
  /// Converts a parsed sequence into a key event if possible.
  ///
  /// Not all parsed sequences can be converted to key events. This property
  /// returns `nil` for sequences that represent non-key events (like unknown
  /// sequences) or sequences that don't map to keyboard input.
  ///
  /// The conversion handles:
  /// - Regular characters as character key events
  /// - Escape sequences as escape key events
  /// - Cursor movement sequences as arrow key events
  /// - Function key sequences as function key events
  ///
  /// ## Usage Example
  /// ```swift
  /// var buffer = ByteBufferAllocator().buffer(capacity: inputBytes.count)
  /// buffer.writeBytes(inputBytes)
  /// let sequences = parser.parse(&buffer)
  /// for sequence in sequences {
  ///   if let keyEvent = sequence.event {
  ///     handleKeyInput(keyEvent)
  ///   } else {
  ///     // Handle non-key sequence (like unknown/malformed input)
  ///     handleUnknownSequence(sequence)
  ///   }
  /// }
  /// ```
  ///
  /// - Returns: A `KeyEvent` if the sequence represents keyboard input,
  ///   `nil` otherwise.
  internal var event: KeyEvent? {
    switch self {
    case let .character(character):
      if character == "\u{1b}" {
        KeyEvent(character: character, keycode: .escape, modifiers: [], type: .press)
      } else {
        KeyEvent(character: character, keycode: KeyCode(0), modifiers: [], type: .press)
      }

    case let .cursor(direction, _):
      switch direction {
      case .up:
        KeyEvent(
          character: nil,
          keycode: .up,
          modifiers: [],
          type: .press
        )
      case .down:
        KeyEvent(
          character: nil,
          keycode: .down,
          modifiers: [],
          type: .press
        )
      case .left:
        KeyEvent(
          character: nil,
          keycode: .left,
          modifiers: [],
          type: .press
        )
      case .right:
        KeyEvent(
          character: nil,
          keycode: .right,
          modifiers: [],
          type: .press
        )
      }

    case let .function(number, modifiers):
      KeyEvent(
        character: nil,
        keycode: KeyCode(UInt16(Int(KeyCode.F1.rawValue) + number - 1)),
        modifiers: modifiers,
        type: .press
      )

    case .unknown(_):
      nil
    }
  }
}

extension ByteBuffer {
  func getByte() -> UInt8? {
    self.getInteger(at: self.readerIndex)
  }

  mutating func readByte() -> UInt8? {
    self.readInteger()
  }
}
