import OrderedCollections

public struct HTMLString: Sendable, ExpressibleByStringInterpolation, Hashable, CustomStringConvertible {
  fileprivate var renderer = HTMLRenderer()

  public var rawValue: String { self.renderer.output }

  public var description: String { self.rawValue }

  public init() {}

  public init(stringLiteral value: String) {
    self.renderer.output = value
  }

  public init(stringInterpolation: StringInterpolation) {
    self.renderer = stringInterpolation.renderer
  }

  public mutating func append(_ html: HTMLString) {
    self.renderer.append(html.renderer)
  }

  public struct StringInterpolation: StringInterpolationProtocol {
    fileprivate var renderer = HTMLRenderer()

    public init(literalCapacity: Int, interpolationCount: Int) {
      self.renderer.output.reserveCapacity(literalCapacity + interpolationCount * 16)
    }

    public mutating func appendLiteral(_ literal: String) {
      self.renderer.output.append(literal)
    }

    public mutating func appendInterpolation(_ html: some HTML) {
      html.render(into: &self.renderer)
    }

    public mutating func appendInterpolation<T: HTML>(@HTMLBuilder _ html: () -> T) {
      html().render(into: &self.renderer)
    }

    public mutating func appendInterpolation(unsafe string: some StringProtocol) {
      self.renderer.output.append(contentsOf: string)
    }

    /// Renders `name="value"` pairs separated by spaces, escaping each value and omitting `nil` ones.
    public mutating func appendInterpolation(attributes: KeyValuePairs<String, String?>) {
      var isFirst = true
      for case let (name, value?) in attributes {
        if !isFirst { self.renderer.output.append(" ") }
        isFirst = false
        self.renderer.output.append(name)
        self.renderer.output.append("=\"")
        self.renderer.output.append(.escapingHTML(value))
        self.renderer.output.append("\"")
      }
    }
  }
}

public protocol HTML {
  associatedtype _Body: HTML = HTMLString

  typealias Body = _Body

  @HTMLBuilder var body: Body { get }

  func render(into renderer: inout HTMLRenderer)

  static var styles: String { get }
  static var scripts: String { get }
}

extension HTML {
  public static var styles: String { "" }
  public static var scripts: String { "" }

  public func render(into renderer: inout HTMLRenderer) {
    if !Self.styles.isEmpty {
      renderer.globalStyles[ObjectIdentifier(Self.self)] = Self.styles
    }
    if !Self.scripts.isEmpty {
      renderer.globalScripts[ObjectIdentifier(Self.self)] = Self.scripts
    }
    self.body.render(into: &renderer)
  }
}

public struct HTMLRenderer: Sendable, Hashable {
  public var output = String()
  public var globalStyles = OrderedDictionary<ObjectIdentifier, String>()
  public var globalScripts = OrderedDictionary<ObjectIdentifier, String>()

  public mutating func append(_ other: HTMLRenderer) {
    self.output.append(other.output)
    self.globalStyles.merge(other.globalStyles) { current, _ in current }
    self.globalScripts.merge(other.globalScripts) { current, _ in current }
  }
}

// MARK: - Builder

@resultBuilder
public enum HTMLBuilder {
  public static func buildExpression(_ html: HTMLString) -> HTMLString {
    html
  }

  @_disfavoredOverload
  public static func buildExpression(_ html: some HTML) -> HTMLString {
    var output = HTMLString()
    html.render(into: &output.renderer)
    return output
  }

  public static func buildBlock() -> HTMLString {
    HTMLString()
  }

  public static func buildPartialBlock(first html: HTMLString) -> HTMLString {
    html
  }

  public static func buildPartialBlock(accumulated: consuming HTMLString, next: HTMLString) -> HTMLString {
    accumulated.append(next)
    return accumulated
  }

  public static func buildOptional(_ html: HTMLString?) -> HTMLString {
    html ?? HTMLString()
  }

  public static func buildEither(first html: HTMLString) -> HTMLString {
    html
  }

  public static func buildEither(second html: HTMLString) -> HTMLString {
    html
  }

  public static func buildLimitedAvailability(_ html: HTMLString) -> HTMLString {
    html
  }

  public static func buildArray(_ html: [HTMLString]) -> HTMLString {
    var output = HTMLString()
    for element in html {
      output.append(element)
    }
    return output
  }
}

// MARK: - Conformances

extension HTMLString: HTML {
  public var body: HTMLString { self }

  public func render(into renderer: inout HTMLRenderer) {
    renderer.append(self.renderer)
  }
}

extension String: HTML {
  // `String` is also a swift-parsing `Parser` with its own `body`, so `_Body` can't be inferred.
  public typealias _Body = HTMLString

  public var body: HTMLString { HTMLString(stringLiteral: .escapingHTML(self)) }
}

extension Substring: HTML {
  public var body: HTMLString { HTMLString(stringLiteral: .escapingHTML(self)) }
}

extension Int: HTML {
  public var body: HTMLString { HTMLString(stringLiteral: String(self)) }
}

extension Optional: HTML where Wrapped: HTML {
  public var body: HTMLString {
    if case let html? = self { html }
  }
}

extension Array: HTML where Element: HTML {
  public var body: HTMLString {
    for element in self { element }
  }
}

extension String {
  fileprivate static func escapingHTML(_ string: some StringProtocol) -> String {
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
    return output
  }
}
