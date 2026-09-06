import Dependencies
import Foundation
import HTTPTypes
import Hummingbird
import HummingbirdElementary
import HummingbirdRouter
import Parsing
import Shared
import URLRouting

struct SiteMiddleware<Context: RequestContext>: RouterMiddleware {
  @Dependency(\.siteRouter) private var router
  @Dependency(\.currentRoute) private var currentRoute
  @Dependency(\.activityClient) private var activityClient

  func handle(_ request: Request, context: Context, next: (Request, Context) async throws -> Response) async throws -> Response {
    do {
      let response: any ResponseGenerator = try await withDependencies {
        $0.currentRoute = try await self.router.parse(self.parse(request: request))
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
          if request.headers[.hx.request] == String(true) {
            return HTMLResponse {
              ActivityFragment()
            }
          }
          do {
            return try Activity.encoder.encode(self.activityClient.activity(), from: request, context: context)
          } catch {
            throw HTTPError(.badRequest)
          }
        case let .api(.activity(.location(location))):
          try request.headers.verifyAuthorization()
          self.activityClient.updateLocation(location)
          return Response(status: .ok)
        case let .api(.activity(.nowPlaying(nowPlaying))):
          try request.headers.verifyAuthorization()
          self.activityClient.updateNowPlaying(nowPlaying)
          return Response(status: .ok)
        case .page(.home):
          return HTMLResponse { 
            HomePage() 
          }
        case .page(.devLogs):
          return HTMLResponse { 
            DevLogsPage() 
          }
        case .page(.showcase):
          return HTMLResponse { 
            ShowcasePage()
          }
        }
      }
      return try response.response(from: request, context: context)
    } catch let routingError {
      do {
        return try await next(request, context)
      } catch {
        #if DEBUG
          context.logger.debug("Routing error \(routingError)")
          throw HTTPError(.notFound, message: "Routing error: \(routingError)")
        #else
          throw error
        #endif
      }
    }
  }

  private func parse(request: Request) async throws -> URLRequestData {
    var body: ByteBuffer?
    do {
      for try await var buffer in request.body {
        body.setOrWriteBuffer(&buffer)
      }
    } catch {
      body = nil
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
