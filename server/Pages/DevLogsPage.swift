import Elementary
import Hummingbird
import HummingbirdElementary
import URLRouting

struct DevLogsPage: HTML {
  var body: some HTML {
    PageLayout(pageTitle: "dev-logs") {
      BlockSection {
        p { "Coming Soon" }
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
