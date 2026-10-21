import CasePaths
import Foundation
import Shared
import URLRouting

extension SiteRoute {
  @CasePathable
  enum APIRoute: Sendable, Equatable {
    case activity(ActivityRoute)

    #if DEBUG
      case liveReload(build: String)
    #endif
  }
}

extension SiteRoute.APIRoute {
  @CasePathable
  enum ActivityRoute: Sendable, Equatable {
    case all
    case location(Activity.Location?)
    case nowPlaying(Activity.NowPlaying?)
  }
}

extension SiteRoute.APIRoute {
  struct Router: Sendable, ParserPrinter {
    typealias BaseRoute = SiteRoute.APIRoute

    var body: some URLRouting.Router<BaseRoute> {
      OneOf {
        Route(.case(\.activity) as AnyCasePath<BaseRoute, BaseRoute.ActivityRoute>) {
          Path { "activity" }

          OneOf {
            Route(.case(BaseRoute.ActivityRoute.all))

            Route(.case(\BaseRoute.ActivityRoute.Cases.location)) {
              Method.post
              Path { "location" }
              Optionally {
                Body(.json(Activity.Location.self, decoder: Activity.decoder, encoder: Activity.encoder))
              }
            }

            Route(.case(\BaseRoute.ActivityRoute.Cases.nowPlaying)) {
              Method.post
              Path { "now-playing" }
              Optionally {
                Body(.json(Activity.NowPlaying.self, decoder: Activity.decoder, encoder: Activity.encoder))
              }
            }
          }
        }

        #if DEBUG
          Route(.case(\BaseRoute.Cases.liveReload)) {
            Method.get
            Path { "live-reload" }
            Query {
              Field("tag", .string)
            }
          }
        #endif
      }
    }
  }
}
