public struct Post: Sendable {
  public enum Header: Sendable {
    // case link(String)
    case image(GeneratedPublicAssets.ImageFile, label: String)
    case video(GeneratedPublicAssets.VideoFile)
    case code(String, lang: CodeLang)
  }

  public enum Kind: String, Hashable, CaseIterable, Sendable {
    case blog
    case project
    case education
    case experience

    public var tabTitle: StaticString {
      switch self {
      case .blog: "Blog"
      case .project: "Projects"
      case .education: "Education"
      case .experience: "Experiences"
      }
    }
  }

  public struct TextContent: Sendable {
    public enum Element: Sendable {
      case text(StaticString)
      case link(title: StaticString, url: StaticString)
      // case code()

      var rawValue: StaticString {
        switch self {
        case .text(let value): value
        case .link(let value, _): value
        }
      }
    }

    public private(set) var content: [Element] = []

    public var rawValue: String {
      content.compactMap {$0.rawValue.withUTF8Buffer { ptr in String(decoding: ptr, as: UTF8.self) }}
        .joined()
    }
  }

  public struct Date: Comparable, Sendable {
    let month: Int
    let day: Int
    let year: Int

    public static func < (lhs: Post.Date, rhs: Post.Date) -> Bool {
      (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }
  }

  public struct Link: Sendable {
    public enum Role: String, CaseIterable, Hashable, Sendable {
      case primary
      case secondary
    }

    public let title: String
    public let href: String
    public let role: Role

    public var isExternal: Bool { self.href.utf8.first != 0x2F }
  }

  public internal(set) var header: Header?
  public let title: TextContent
  public let content: TextContent
  public let date: Date
  public internal(set) var lastUpdated: Date?
  public let kind: Kind
  public internal(set) var links: [Link] = []
  public internal(set) var hidden = false

  public var datePosted: String {
    "\(self.date.month)/\(self.date.day)/\(self.date.year)"
  }

  public var dateUpdated: String? {
    if let lastUpdated {
      "\(lastUpdated.month)/\(lastUpdated.day)/\(lastUpdated.year)"
    } else {
      nil
    }
  }

  public var slug: String {
    "\(self.date.year)\(self.date.month)\(self.date.day)-\(self.title.rawValue.split { !$0.isLetter && !$0.isNumber }.joined(separator: "-").lowercased())"
  }
}

extension Post.TextContent: ExpressibleByStringInterpolation {
  public struct StringInterpolation: StringInterpolationProtocol {
    var storage: [Post.TextContent.Element] = []

    public init(literalCapacity: Int, interpolationCount: Int) {
      self.storage.reserveCapacity(literalCapacity + interpolationCount)
    }

    public mutating func appendLiteral(_ literal: StaticString) {
      self.storage.append(.text(literal))
    }

    public mutating func appendInterpolation(_ value: StaticString) {
      self.storage.append(.text(value))
    }

    public mutating func appendInterpolation(_ title: StaticString, url: StaticString) {
      self.storage.append(.link(title: title, url: url))
    }
  }

  public init(stringLiteral value: StaticString) {
    self.init()
    self.content.append(.text(value))
  }

  public init(stringInterpolation: StringInterpolation) {
    self.init()
    self.content.append(contentsOf: stringInterpolation.storage)
  }
}
