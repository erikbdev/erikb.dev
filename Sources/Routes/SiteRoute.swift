#if !hasFeature(Embedded)
import CasePaths
import Foundation
import URLRouting
#endif


#if !hasFeature(Embedded)
@CasePathable
#endif
public enum SiteRoute: Sendable, Equatable {
  case pages(PageRoute)
  case api(APIRoute)

  public static let index = Self.pages(.home)
}

#if !hasFeature(Embedded)
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
#endif