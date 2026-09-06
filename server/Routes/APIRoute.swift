import CasePaths
import Foundation
import Shared
import URLRouting

extension SiteRoute {
  @CasePathable
  public enum APIRoute: Sendable, Equatable {
    case activity(ActivityRoute)

    #if DEBUG
      case liveReload(build: String)
    #endif
  }
}

extension SiteRoute.APIRoute {
  @CasePathable
  public enum ActivityRoute: Sendable, Equatable {
    case all
    case location(Activity.Location?)
    case nowPlaying(Activity.NowPlaying?)
  }
}

extension SiteRoute.APIRoute {
  public struct Router: Sendable, ParserPrinter {
    public var body: some URLRouting.Router<SiteRoute.APIRoute> {
      OneOf {
        Route(.case(\SiteRoute.APIRoute.Cases.activity)) {
          Path { "activity" }

          OneOf {
            Route(.case(SiteRoute.APIRoute.ActivityRoute.all))

            Route(.case(\SiteRoute.APIRoute.ActivityRoute.Cases.location)) {
              Method.post
              Path { "location" }
              Optionally {
                Body(.json(Activity.Location.self, decoder: Activity.decoder, encoder: Activity.encoder))
              }
            }

            Route(.case(\SiteRoute.APIRoute.ActivityRoute.Cases.nowPlaying)) {
              Method.post
              Path { "now-playing" }
              Optionally {
                Body(.json(Activity.NowPlaying.self, decoder: Activity.decoder, encoder: Activity.encoder))
              }
            }
          }
        }

        #if DEBUG
          Route(.case(\SiteRoute.APIRoute.Cases.liveReload)) {
            Method.post
            Path { "live-reload" }
            Query {
              Field("rev", .string)
            }
          }
        #endif
      }
    }
  }
}
