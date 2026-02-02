// struct Color: Component {}

public struct Color {
  enum Backing {
    case ansi(ANSI, Intensity)
    case rgb(_ red: UInt8, _ green: UInt8, _ blue: UInt8)
  }

  enum Intensity {
    case normal 
    case bright
  }

  enum ANSI: Int {
    case black = 0
    case red
    case green
    case yellow
    case blue
    case purple
    case cyan
    case white

    case `default` = 9
  }

  let backing: Backing

  private init(_ backing: Backing) {
    self.backing = backing
  }

  public func brightend() -> Color {
    guard case let .ansi(ansi, intensity) = self.backing else {
      return self
    }
    return Color(.ansi(ansi, intensity))
  }
}

extension Color {
  static func ansi(_ ansi: ANSI, _ intensity: Intensity = .normal) -> Self {
    Self(.ansi(ansi, intensity))
  }

  static func rgb(_ red: UInt8, _ green: UInt8, _ blue: UInt8) -> Self {
    Self(.rgb(red, green, blue))
  }

  static var `default`: Self {
    .ansi(.default)
  }

  static var black: Self {
    .ansi(.black)
  }

  static var red: Self {
    .ansi(.red)
  }

  static var green: Self {
    .ansi(.green)
  }

  static var yellow: Self {
    .ansi(.yellow)
  }

  static var blue: Self {
    .ansi(.blue)
  }

  static var purple: Self {
    .ansi(.purple)
  }

  static var cyan: Self {
    .ansi(.cyan)
  }

  static var white: Self {
    .ansi(.white)
  }
}

extension Color: Component {
  func render(into renderer: inout VTBuffer) {
  }
}