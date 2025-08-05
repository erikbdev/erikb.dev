import Dependencies
import HTML
import Vue

public enum CodeLang: String, Hashable, Encodable, CaseIterable, Sendable, RawRepresentable {
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

  @HTMLBuilder static func conditionalCases<Content: HTML>(
    initial selected: Vue.Expression<CodeLang>,
    @HTMLBuilder content: (CodeLang) -> Content
  ) -> some HTML {
    let allCodeLangs = [selected.initialValue] + Self.allCases.filter { $0 != selected.initialValue }
    for (idx, lang) in allCodeLangs.enumerated() {
      content(lang)
        .attribute(
          "v-cloak",
          value: idx == allCodeLangs.startIndex ? nil : ""
        )
        .attribute(
          "v-if",
          value: idx == allCodeLangs.startIndex ? (selected == Expression(lang)).rawValue : nil
        )
        .attribute(
          "v-else-if",
          value: allCodeLangs.startIndex < idx
            && idx < allCodeLangs.index(before: allCodeLangs.endIndex)
            ? (selected == Expression(lang)).rawValue : nil
        )
        .attribute(
          "v-else",
          value: idx == allCodeLangs.index(before: allCodeLangs.endIndex) ? "" : nil
        )
    }
  }
}
