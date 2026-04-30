import CasePaths
import Foundation
import URLRouting

@CasePathable
public enum SiteRoute: Sendable, Equatable {
  case api(APIRoute)
}

extension SiteRoute {
  public struct Router: Sendable, ParserPrinter {
    public init() {}

    public var body: some URLRouting.Router<SiteRoute> {
      OneOf {
        Route(.case(SiteRoute.api)) {
          Path { "api" }
          APIRoute.Router()
        }
      }
    }
  }
}