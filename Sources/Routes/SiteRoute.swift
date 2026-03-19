import CasePaths
import Foundation
import URLRouting

@CasePathable
public enum SiteRoute: Sendable, Equatable {
  case pages(PageRoute)
  case api(APIRoute)

  public static let index = Self.pages(.home)
}

extension SiteRoute {
  public struct Router: Sendable, ParserPrinter {
    public init() {}

    public var body: some URLRouting.Router<SiteRoute> {
      OneOf {
        Route(.case(SiteRoute.pages)) {
          PageRoute.Router()
        }

        Route(.case(SiteRoute.api)) {
          Path { "api" }
          APIRoute.Router()
        }
      }
    }
  }
}
