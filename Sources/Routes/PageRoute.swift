import CasePaths
import URLRouting

extension SiteRoute {
  @CasePathable
  public enum PageRoute: Sendable, Equatable {
    case home
    case notFound
  }
}

extension SiteRoute.PageRoute {
  struct Router: Sendable, ParserPrinter {
    var body: some URLRouting.Router<SiteRoute.PageRoute> {
      OneOf {
        Route(.case(SiteRoute.PageRoute.home))
      }
    }
  }
}