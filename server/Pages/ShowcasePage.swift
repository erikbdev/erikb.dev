import Hummingbird
import URLRouting

struct ShowcasePage: HTML {
  var body: some HTML {
    PageLayout(title: "showcase") {
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
