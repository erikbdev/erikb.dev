import Markdown
import Shared

struct MarkdownHTML: HTML.Component {
  var markdown: String

  var body: HTML {
    HTML(stringLiteral: HTMLFormatter.format(markdown))
  }
}
