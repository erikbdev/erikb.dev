public struct HTML: Sendable, Hashable, ExpressibleByStringInterpolation, CustomStringConvertible {
  public let rawValue: String

  public var description: String { rawValue }

  public init() {
    self.rawValue = ""
  }

  public init(unsafe string: String) {
    self.rawValue = string
  }

  public init(stringLiteral value: String) {
    self.rawValue = value
  }

  public init(stringInterpolation: StringInterpolation) {
    self.rawValue = stringInterpolation.output
  }

  public struct StringInterpolation: StringInterpolationProtocol {
    fileprivate var output: String

    public init(literalCapacity: Int, interpolationCount: Int) {
      output = ""
      output.reserveCapacity(literalCapacity + interpolationCount * 16)
    }

    public mutating func appendLiteral(_ literal: String) {
      output.append(literal)
    }

    public mutating func appendInterpolation(_ html: some HTML.Component) {
      output.append(html.body.rawValue)
    }

    public mutating func appendInterpolation<S: Sequence>(_ html: S) where S.Element: HTML.Component {
      for element in html {
        output.append(element.body.rawValue)
      }
    }

    public mutating func appendInterpolation(_ string: some StringProtocol) {
      output.appendEscapingHTML(string)
    }

    public mutating func appendInterpolation(@HTML.Builder html: () -> HTML) -> HTML {
      html()
    }

    public mutating func appendInterpolation(unsafe string: some StringProtocol) {
      output.append(contentsOf: string)
    }

    @_disfavoredOverload
    public mutating func appendInterpolation<T>(_ value: T) {
      output.appendEscapingHTML(String(describing: value))
    }
  }
}

extension String {
  fileprivate mutating func appendEscapingHTML(_ string: some StringProtocol) {
    let utf8 = string.utf8
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
        append(contentsOf: string[runStart..<index])
        append(replacement)
        runStart = utf8.index(after: index)
      }
      index = utf8.index(after: index)
    }

    append(contentsOf: string[runStart..<utf8.endIndex])
  }
}

extension HTML {
  public protocol Component {
    @HTML.Builder var body: HTML { get }
  }

  @resultBuilder
  public enum Builder {
    public static func buildExpression(_ html: HTML) -> HTML {
      html
    }

    public static func buildExpression(_ html: some Component) -> HTML {
      html.body
    }

    public static func buildBlock(_ html: HTML) -> HTML {
      html
    }

    public static func buildBlock(_ html: HTML...) -> HTML {
      join(html)
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

    public static func buildArray(_ html: [HTML]) -> HTML {
      join(html)
    }

    private static func join(_ html: [HTML]) -> HTML {
      guard html.count > 1 else { return html.first ?? HTML() }
      var output = ""
      output.reserveCapacity(html.reduce(0) { $0 + $1.rawValue.utf8.count })
      for element in html {
        output.append(element.rawValue)
      }
      return HTML(unsafe: output)
    }
  }
}

extension HTML: HTML.Component {
  public var body: HTML { self }
}
