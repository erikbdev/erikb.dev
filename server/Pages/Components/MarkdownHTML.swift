import Markdown
import Shared

struct MarkdownHTML: HTML.Component {
  var markdown: String

  var body: HTML {
    HTML(unsafe: HTMLFormatter.format(markdown))
  }
}
