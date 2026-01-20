struct ANSI: Sendable, Hashable {
  let rawValue: [UInt8]
  fileprivate init(rawValue: [UInt8]) {
    self.rawValue = rawValue
  }
}

extension ANSI {
  // Sequences
  static let esc = Self(rawValue: [0x1B])
  static let csi = Self(rawValue: [0x9B])
  static let dcs = Self(rawValue: [0x90])
  static let osc = Self(rawValue: [0x9D])

  // C0 Control Characters
  static let backspace = Self(rawValue: [0x08])
  static let tab = Self(rawValue: [0x09])
  static let lf = Self(rawValue: [0x0A])
  static let cr = Self(rawValue: [0x0D])


  // CSI sequences
  static let clear = Self(rawValue: esc.rawValue + [0x5B, 0x32, 0x4A])  // \u{1B}[2J
  static let home = Self(rawValue: esc.rawValue + [0x5B, 0x48])  // \u{1B}[H
  static let reset = Self(rawValue: esc.rawValue + [0x5B, 0x30, 0x6D])  // \u{1B}[0m

  static func color(_ color: Color) -> Self {
    Self(rawValue: esc.rawValue + [0x5B, color.rawValue])  // \u{1B}[<color code>m
  }

  enum Color: UInt8, Hashable, Sendable {
    case black = 30
    case red = 31
    case green = 32
    case yellow = 33
    case blue = 34
    case magenta = 35
    case cyan = 36
    case white = 37
  }
}
