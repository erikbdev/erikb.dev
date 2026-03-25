#if !os(WASI)
import CasePaths
import Foundation
import URLRouting
#endif
import Models

extension SiteRoute {
  #if !os(WASI)
  @CasePathable
  #endif
  public enum APIRoute: Sendable, Equatable {
    case activity(ActivityRoute)
  }
}

extension SiteRoute.APIRoute {
  #if !os(WASI)
  @CasePathable
  #endif
  public enum ActivityRoute: Sendable, Equatable {
    case all
    case location(Activity.Location?)
    case nowPlaying(Activity.NowPlaying?)
  }
}


#if !os(WASI)
extension SiteRoute.APIRoute {
  struct Router: Sendable, ParserPrinter {
    var body: some URLRouting.Router<SiteRoute.APIRoute> {
      OneOf {
        Route(.case(SiteRoute.APIRoute.activity)) {
          Path { "activity" }

          OneOf {
            Route(.case(SiteRoute.APIRoute.ActivityRoute.all))

            Route(.case(SiteRoute.APIRoute.ActivityRoute.location)) {
              Method.post
              Path { "location" }
              Optionally {
                Body(.json(Activity.Location.self, decoder: Activity.decoder, encoder: Activity.encoder))
              }
            }

            Route(.case(SiteRoute.APIRoute.ActivityRoute.nowPlaying)) {
              Method.post
              Path { "now-playing" }
              Optionally {
                Body(.json(Activity.NowPlaying.self, decoder: Activity.decoder, encoder: Activity.encoder))
              }
            }
          }
        }
      }
    }
  }
}
#endif