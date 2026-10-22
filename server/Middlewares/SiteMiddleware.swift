import Dependencies
import Foundation
import HTTPTypes
import Hummingbird
import HummingbirdRouter
import Parsing
import Shared
import URLRouting

struct SiteMiddleware<Context: RequestContext>: RouterMiddleware {
  @Dependency(\.router) private var router
  @Dependency(\.currentRoute) private var currentRoute
  @Dependency(\.activityClient) private var activityClient

  func handle(_ request: Request, context: Context, next: (Request, Context) async throws -> Response) async throws -> Response {
    let route: SiteRoute

    do {
      route = try await self.router.parse(self.parse(request: request))
    } catch let routingError {
      context.logger.debug("Routing error \(routingError)")
      return try await next(request, context)
    }

    return try withDependencies {
      $0.currentRoute = route
    } operation: {
      switch currentRoute {
      #if DEBUG
        case .api(.liveReload(let timestamp)):
          return Response(
            status: .ok,
            headers: [.hx.refresh: String(timestamp != buildTimestamp)]
          )
      #endif
      case .api(.activity(.all)):
        do {
          return try Activity.encoder.encode(self.activityClient.activity().redacted, from: request, context: context)
        } catch {
          throw HTTPError(.badRequest)
        }
      case let .api(.activity(.location(location))):
        try request.verifyAuthorization()
        self.activityClient.updateLocation(location)
        return Response(status: .ok)
      case let .api(.activity(.nowPlaying(nowPlaying))):
        try request.verifyAuthorization()
        self.activityClient.updateNowPlaying(nowPlaying)
        return Response(status: .ok)
      case .page(.index):
        return IndexPage()
          .response()
      case .page(.devLogs):
        return DevLogsPage()
          .response()
      case .page(.showcase):
        return ShowcasePage()
          .response()
      }
    }
  }

  private func parse(request: Request) async throws -> URLRequestData {
    var body: ByteBuffer?
    for try await var buffer in request.body {
      body.setOrWriteBuffer(&buffer)
    }

    let authorization = request.headers.basicAuthentication

    return URLRequestData(
      method: request.method.rawValue,
      scheme: request.uri.scheme?.rawValue,
      user: authorization?.0,
      password: authorization?.1,
      host: request.uri.host,
      port: request.uri.port,
      path: request.uri.path,
      query: request.uri.queryParameters.reduce(into: [:]) { dict, item in
        dict[String(item.key), default: []].append(String(item.value))
      },
      fragment: request.uri.string.range(of: "#").flatMap { range in
        String(request.uri.string[request.uri.string.index(after: range.lowerBound)...])
      },
      headers: request.headers.reduce(into: [:]) { dict, item in
        dict[item.name.canonicalName, default: []].append(contentsOf: item.value.components(separatedBy: ","))
      },
      body: body.flatMap { Data(buffer: $0) }
    )
  }
}
