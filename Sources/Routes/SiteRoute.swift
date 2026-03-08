import CasePaths
import Foundation
import URLRouting

@CasePathable
public enum SiteRoute: Sendable, Equatable {
  case home
  case api(APIRoute)

  public static let index = Self.home
}

extension SiteRoute {
  public struct Router: Sendable, ParserPrinter {
    public init() {}

    public var body: some URLRouting.Router<SiteRoute> {
      OneOf {
        Route(.case(SiteRoute.home))

        Route(.case(SiteRoute.api)) {
          Path { "api" }
          APIRoute.Router()
        }
      }
    }
  }
}
