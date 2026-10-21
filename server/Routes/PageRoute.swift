import CasePaths
import URLRouting

extension SiteRoute {
  @CasePathable
  enum PageRoute: Sendable, Equatable {
    case index(IndexRoute?)
    case devLogs
    case showcase
  }
}

extension SiteRoute.PageRoute {
  struct Router: Sendable, ParserPrinter {
    typealias BaseRoute = SiteRoute.PageRoute

    init() {}

    var body: some URLRouting.Router<BaseRoute> {
      OneOf {
        Route(.case(\BaseRoute.Cases.index)) {
          IndexRoute.Router()
        }
        Route(.case(\BaseRoute.Cases.devLogs)) {
          DevLogsPage.Router()
        }
        Route(.case(\BaseRoute.Cases.showcase)) {
          ShowcasePage.Router()
        }
      }
    }
  }
}
