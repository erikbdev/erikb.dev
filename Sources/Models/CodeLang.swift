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

  func fileNameSlug(from value: String) -> String {
    let components = value
      .split { $0 == "-" || $0 == " " }
      .map { $0.lowercased() }
      .filter { !$0.isEmpty }
      .compactMap { String($0) }
    let fileName: String = switch self {
    case .markdown, .rust:
      components.joined(separator: "-")
    case .swift:
      components.map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined()
    case .typescript:
      components.enumerated().map { idx, part in
        idx == 0 ? part : part.prefix(1).uppercased() + part.dropFirst()
      }
      .joined()
    }
    return fileName + "." + self.ext
  }
}
