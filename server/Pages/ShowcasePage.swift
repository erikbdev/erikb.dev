import Hummingbird
import URLRouting

struct ShowcasePage: HTML.Component {
  var body: HTML {
    PageLayout(pageTitle: "showcase") {
      BlockSection {
        /* html */
        "<p>Coming Soon</p>"
      }
    }
  }
}

extension ShowcasePage {
  struct Router: Sendable, ParserPrinter {
    init() {}

    var body: some URLRouting.Router<Void> {
      Path { "showcase" }
    }
  }
}
