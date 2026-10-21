@resultBuilder
public struct HTML: Sendable, ExpressibleByStringInterpolation, Hashable, CustomStringConvertible {
  public private(set) var rawValue: String

  public var description: String { self.rawValue }

  public init() {
    self.rawValue = ""
  }

  public init(stringLiteral value: String) {
    self.rawValue = value
  }

  public init(stringInterpolation: StringInterpolation) {
    self.rawValue = stringInterpolation.output
  }

  public mutating func append(_ html: HTML) {
    self.rawValue.append(html.rawValue)
  }

  public struct StringInterpolation: StringInterpolationProtocol {
    fileprivate var output: String

    public init(literalCapacity: Int, interpolationCount: Int) {
      self.output = ""
      self.output.reserveCapacity(literalCapacity + interpolationCount * 16)
    }

    public mutating func appendLiteral(_ literal: String) {
      self.output.append(literal)
    }

    public mutating func appendInterpolation(_ html: some HTML.Component) {
      self.output.append(html.body.rawValue)
    }

    public mutating func appendInterpolation(@HTML _ html: () -> HTML) {
      self.output.append(html().rawValue)
    }

    public mutating func appendInterpolation(unsafe string: some StringProtocol) {
      self.output.append(contentsOf: string)
    }
  }
}

extension HTML {
  public protocol Component {
    @HTML var body: HTML { get }
  }
}

// MARK: - Builder

extension HTML {
  public static func buildExpression(_ html: HTML) -> HTML {
    html
  }

  @_disfavoredOverload
  public static func buildExpression(_ html: some HTML.Component) -> HTML {
    html.body
  }

  public static func buildBlock() -> HTML {
    HTML()
  }

  public static func buildPartialBlock(first html: HTML) -> HTML {
    html
  }

  public static func buildPartialBlock(accumulated: consuming HTML, next: HTML) -> HTML {
    accumulated.append(next)
    return accumulated
  }

  public static func buildOptional(_ html: HTML?) -> HTML {
    html ?? HTML()
  }

  public static func buildEither(first html: HTML) -> HTML {
    html
  }

  public static func buildEither(second html: HTML) -> HTML {
    html
  }

  public static func buildLimitedAvailability(_ html: HTML) -> HTML {
    html
  }

  public static func buildArray(_ html: [HTML]) -> HTML {
    var output = HTML()
    output.rawValue.reserveCapacity(html.reduce(0) { $0 + $1.rawValue.utf8.count })
    for element in html {
      output.append(element)
    }
    return output
  }
}

// MARK: - Conformances

extension HTML: HTML.Component {
  public var body: HTML { self }
}

extension String: HTML.Component {
  public var body: HTML { HTML(escaping: self) }
}

extension Substring: HTML.Component {
  public var body: HTML { HTML(escaping: self) }
}

extension Int: HTML.Component {
  public var body: HTML { HTML(stringLiteral: String(self)) }
}

extension Optional: HTML.Component where Wrapped: HTML.Component {
  public var body: HTML { self?.body ?? HTML() }
}

extension Array: HTML.Component where Element: HTML.Component {
  public var body: HTML { HTML.buildArray(map(\.body)) }
}

extension HTML {
  fileprivate init(escaping string: some StringProtocol) {
    let utf8 = string.utf8
    var output = ""
    output.reserveCapacity(utf8.count)
    var runStart = utf8.startIndex
    var index = runStart

    while index != utf8.endIndex {
      let replacement: String? =
        switch utf8[index] {
        case UInt8(ascii: "&"): "&amp;"
        case UInt8(ascii: "<"): "&lt;"
        case UInt8(ascii: ">"): "&gt;"
        case UInt8(ascii: "\""): "&quot;"
        case UInt8(ascii: "'"): "&#39;"
        default: nil
        }

      if let replacement {
        // Reserved characters are ASCII, so `runStart..<index` is always on scalar boundaries.
        output.append(contentsOf: string[runStart..<index])
        output.append(replacement)
        runStart = utf8.index(after: index)
      }
      index = utf8.index(after: index)
    }

    output.append(contentsOf: string[runStart..<utf8.endIndex])
    self.rawValue = output
  }
}
