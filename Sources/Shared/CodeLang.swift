public enum CodeLang: String, Hashable, CaseIterable, Sendable, RawRepresentable {
  case markdown
  case swift
  case rust
  case typescript

  public init(rawValue: String) {
    self = Self.allCases.first(where: { $0.rawValue == rawValue }) ?? .markdown
  }

  public var title: String {
    switch self {
    case .markdown: "Markdown"
    case .swift: "Swift"
    case .rust: "Rust"
    case .typescript: "TypeScript"
    }
  }

  public var ext: String {
    switch self {
    case .markdown: "md"
    case .swift: "swift"
    case .rust: "rs"
    case .typescript: "ts"
    }
  }

  public var hasSemiColon: Bool {
    switch self {
    case .swift, .markdown: false
    default: true
    }
  }

  public static func slugToFileName(_ slug: String, lang: CodeLang) -> String {
    let fileName =
      switch lang {
      case .markdown: slug
      case .swift:
        slug.split(separator: "-")
          .map { component -> String in
            if let first = component.first {
              String(first.uppercased() + component.dropFirst())
            } else {
              String(component)
            }
          }
          .joined()
      case .rust: slug
      case .typescript:
        slug.split(separator: "-")
          .enumerated()
          .map { (idx, component) -> String in
            if idx == 0 {
              String(component)
            } else if let first = component.first {
              String(first.uppercased() + component.dropFirst())
            } else {
              String(component)
            }
          }
          .joined()
      }
    return fileName + "." + lang.ext
  }
}
