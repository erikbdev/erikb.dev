#if !hasFeature(Embedded)
import CasePaths
import URLRouting
#endif

extension SiteRoute {
  #if !hasFeature(Embedded)
  @CasePathable
  #endif
  public enum PageRoute: Sendable, Equatable {
    case home
    case notFound
  }
}

#if !hasFeature(Embedded)
extension SiteRoute.PageRoute {
  struct Router: Sendable, ParserPrinter {
    var body: some URLRouting.Router<SiteRoute.PageRoute> {
      OneOf {
        Route(.case(SiteRoute.PageRoute.home))
      }
    }
  }
}
#endif