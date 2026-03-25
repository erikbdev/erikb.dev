#if !os(WASI)
import CasePaths
import URLRouting
#endif

extension SiteRoute {
  #if !os(WASI)
  @CasePathable
  #endif
  public enum PageRoute: Sendable, Equatable {
    case home
    case notFound
  }
}

#if !os(WASI)
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