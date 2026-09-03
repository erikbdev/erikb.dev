import CasePaths
import Foundation
import URLRouting

@CasePathable
public enum SiteRoute: Sendable, Equatable {
  case api(APIRoute)
  case page(PageRoute)
}

extension SiteRoute {
  public struct Router: Sendable, ParserPrinter {
    public init() {}

    public var body: some URLRouting.Router<SiteRoute> {
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