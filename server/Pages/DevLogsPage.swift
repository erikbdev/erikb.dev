import Hummingbird
import URLRouting

struct DevLogsPage: HTML.Component {
  var body: HTML {
    PageLayout(pageTitle: "dev-logs") {
      BlockSection {
        /* html */ "<p>Coming Soon</p>"
      }
    }
  }
}

extension DevLogsPage {
  struct Router: Sendable, ParserPrinter {
    init() {}

    var body: some URLRouting.Router<Void> {
      Path { "dev-logs" }
    }
  }
}
