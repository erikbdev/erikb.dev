import Markdown

public func parseMarkdownDocument(_ text: String) -> Markdown.Document {
  Document(parsing: text)
}
