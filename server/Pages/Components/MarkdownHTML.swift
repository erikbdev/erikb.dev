import Markdown
import Shared

struct MarkdownHTML: HTML {
  var markdown: String

  var body: some HTML {
    HTMLString(stringLiteral: HTMLFormatter.format(markdown))
  }
}
