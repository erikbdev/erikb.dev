import Elementary
import Markdown
import Shared

struct MarkdownHTML: HTML {
  var markdown: String

  var body: some HTML {
    HTMLRaw(HTMLFormatter.format(parseMarkdownDocument(markdown)))
  }
}
