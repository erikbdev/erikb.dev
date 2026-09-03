import CasePaths
import URLRouting

extension SiteRoute {
  @CasePathable
  public enum PageRoute: Sendable, Equatable {
    case home
    case devLogs
    case showcase

    public static let index = PageRoute.home
  }
}

extension SiteRoute.PageRoute {
  public struct Router: Sendable, ParserPrinter {
    public init() {}

    public var body: some URLRouting.Router<SiteRoute.PageRoute> {
      OneOf {
        Route(.case(SiteRoute.PageRoute.home))
        Route(.case(SiteRoute.PageRoute.devLogs)) {
          Path { "dev-logs" }
        }
        Route(.case(SiteRoute.PageRoute.showcase)) {
          Path { "showcase" }
        }
      }
    }
  }
}
