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

    public mutating func appendInterpolation(@HTMLBuilder _ html: () -> some HTML) {
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
        self.renderer.output.append(escapingHTML: value)
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
    renderer.insertAssets(of: Self.self)
    self.body.render(into: &renderer)
  }
}

public struct HTMLRenderer: Sendable, Hashable {
  public var output = String()
  public var globalStyles = OrderedDictionary<ObjectIdentifier, String>()
  public var globalScripts = OrderedDictionary<ObjectIdentifier, String>()

  /// Registers `type`'s styles and scripts, keyed by type so each is emitted once.
  public mutating func insertAssets<T: HTML>(of type: T.Type) {
    if !T.styles.isEmpty {
      self.globalStyles[ObjectIdentifier(T.self)] = T.styles
    }
    if !T.scripts.isEmpty {
      self.globalScripts[ObjectIdentifier(T.self)] = T.scripts
    }
  }

  public mutating func append(_ other: HTMLRenderer) {
    self.output.append(other.output)
    if !other.globalStyles.isEmpty {
      self.globalStyles.merge(other.globalStyles) { current, _ in current }
    }
    if !other.globalScripts.isEmpty {
      self.globalScripts.merge(other.globalScripts) { current, _ in current }
    }
  }
}

// MARK: - Builder

@resultBuilder
public enum HTMLBuilder {
  public static func buildExpression(_ html: HTMLString) -> HTMLString {
    html
  }

  @_disfavoredOverload
  public static func buildExpression<Content: HTML>(_ html: Content) -> Content {
    html
  }

  public static func buildBlock() -> HTMLString {
    HTMLString()
  }

  public static func buildPartialBlock<Content: HTML>(first html: Content) -> Content {
    html
  }

  public static func buildPartialBlock(accumulated: consuming HTMLString, next: some HTML) -> HTMLString {
    next.render(into: &accumulated.renderer)
    return accumulated
  }

  @_disfavoredOverload
  public static func buildPartialBlock(accumulated: some HTML, next: some HTML) -> HTMLString {
    var output = HTMLString()
    accumulated.render(into: &output.renderer)
    next.render(into: &output.renderer)
    return output
  }

  public static func buildOptional<Content: HTML>(_ html: Content?) -> Content? {
    html
  }

  public static func buildEither<First: HTML, Second: HTML>(first html: First) -> _HTMLConditional<First, Second> {
    .first(html)
  }

  public static func buildEither<First: HTML, Second: HTML>(second html: Second) -> _HTMLConditional<First, Second> {
    .second(html)
  }

  /// Erases the type, since an `if #available` branch can't be named outside of it.
  public static func buildLimitedAvailability(_ html: some HTML) -> HTMLString {
    var output = HTMLString()
    html.render(into: &output.renderer)
    return output
  }

  public static func buildArray<Content: HTML>(_ html: [Content]) -> [Content] {
    html
  }
}

/// The result of `if`/`else` and `switch` in an `@HTMLBuilder`. Registers the assets of every branch, renders the
/// active one.
public enum _HTMLConditional<First: HTML, Second: HTML>: HTML {
  case first(First)
  case second(Second)

  public var body: HTMLString { HTMLString() }

  public func render(into renderer: inout HTMLRenderer) {
    renderer.insertAssets(of: First.self)
    renderer.insertAssets(of: Second.self)
    switch self {
    case let .first(html): html.render(into: &renderer)
    case let .second(html): html.render(into: &renderer)
    }
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

  public var body: HTMLString { HTMLString() }

  public func render(into renderer: inout HTMLRenderer) {
    renderer.output.append(escapingHTML: self)
  }
}

extension Substring: HTML {
  public var body: HTMLString { HTMLString() }

  public func render(into renderer: inout HTMLRenderer) {
    renderer.output.append(escapingHTML: self)
  }
}

extension Int: HTML {
  public var body: HTMLString { HTMLString() }

  public func render(into renderer: inout HTMLRenderer) {
    renderer.output.append(String(self))
  }
}

extension Optional: HTML where Wrapped: HTML {
  public var body: HTMLString { HTMLString() }

  public func render(into renderer: inout HTMLRenderer) {
    renderer.insertAssets(of: Wrapped.self)
    self?.render(into: &renderer)
  }
}

extension Array: HTML where Element: HTML {
  public var body: HTMLString { HTMLString() }

  public func render(into renderer: inout HTMLRenderer) {
    for element in self {
      element.render(into: &renderer)
    }
  }
}

extension String {
  /// Appends `string` with HTML-reserved characters escaped.
  fileprivate mutating func append(escapingHTML string: some StringProtocol) {
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
        self.append(contentsOf: string[runStart..<index])
        self.append(replacement)
        runStart = utf8.index(after: index)
      }
      index = utf8.index(after: index)
    }

    self.append(contentsOf: string[runStart..<utf8.endIndex])
  }
}
