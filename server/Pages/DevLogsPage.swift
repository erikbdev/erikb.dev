import Hummingbird
import URLRouting

struct DevLogsPage: HTML {
  var body: some HTML {
    PageLayout(title: "Dev Logs") {
      BlockSection {
        /* html */
        "<p>Coming Soon</p>"
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
