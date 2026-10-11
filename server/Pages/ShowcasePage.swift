import Elementary
import Hummingbird
import HummingbirdElementary
import URLRouting

struct ShowcasePage: HTML {
  var body: some HTML {
    PageLayout(pageTitle: "showcase") {
      BlockSection {
        p { "Coming Soon" }
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
