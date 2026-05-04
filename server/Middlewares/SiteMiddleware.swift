import Dependencies
import Hummingbird
import HummingbirdRouter
import HummingbirdURLRouting
import MiddlewareUtils

import class Foundation.JSONEncoder

struct SiteMiddleware<Context: RequestContext>: RouterController {
  @Dependency(\.siteRouter) private var siteRouter
  @Dependency(\.activity) private var activityClient

  var body: some RouterMiddleware<Context> {
    #if DEBUG
      CORSMiddleware(allowOrigin: .all)
    #endif

    PublicFilesMiddleware()

    URLRoutingMiddleware(self.siteRouter) { req, ctx, route in
      try withDependencies {
        $0.currentRoute = route
      } operation: {
        switch route {
        case .api(.activity(.all)):
          do {
            return try Activity.encoder.encode(self.activityClient.activity()?.redacted, from: req, context: ctx)
          } catch {
            throw HTTPError(.forbidden)
          }
        case let .api(.activity(.location(location))):
          guard let auth = req.headers.authorization else {
            throw HTTPError(.notFound)
          }
          try auth.validate()
          self.activityClient.updateLocation(location)
          return Response(status: .ok)
        case let .api(.activity(.nowPlaying(nowPlaying))):
          guard let auth = req.headers.authorization else {
            throw HTTPError(.notFound)
          }
          try auth.validate()
          self.activityClient.updateNowPlaying(nowPlaying)
          return Response(status: .ok)
        }
      }
    }
  }
}
