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

  var hasSemiColon: Bool {
    switch self {
    case .swift, .markdown: false
    default: true
    }
  }
}