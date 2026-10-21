import CasePaths
import Foundation
import URLRouting

@CasePathable
enum SiteRoute: Sendable, Equatable {
  case api(APIRoute)
  case page(PageRoute)
}

extension SiteRoute {
  struct Router: Sendable, ParserPrinter {
    init() {}

    var body: some URLRouting.Router<SiteRoute> {
      OneOf {
        Route(.case(\SiteRoute.Cases.api)) {
          Path { "api" }
          APIRoute.Router()
        }
        Route(.case(\SiteRoute.Cases.page)) {
          PageRoute.Router()
        }
      }
    }
  }
}
