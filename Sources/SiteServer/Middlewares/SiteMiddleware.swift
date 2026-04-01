import Dependencies
import Elementary
import Hummingbird
import HummingbirdElementary
import HummingbirdRouter
import HummingbirdURLRouting
import MiddlewareUtils
import Models
import Pages
import Routes

import class Foundation.JSONEncoder

struct SiteMiddleware<Context: RequestContext>: RouterController {
  @Dependency(\.siteRouter) private var siteRouter
  @Dependency(\.activity) private var activityClient

  var body: some RouterMiddleware<Context> {
    #if DEBUG
      LiveReloadMiddleware()
      CORSMiddleware(allowOrigin: .all)
    #endif

    NotFoundMiddleware()

    FileMiddleware(searchForIndexHtml: false)

    URLRoutingMiddleware(self.siteRouter) { req, ctx, route in
      try withDependencies {
        $0.currentRoute = route
      } operation: {
        switch route {
        case .pages(.home):
          let codeLang = CodeLang.resolve(req)
          return HTMLResponse {
            PageLayout(metadata: .default(), codeLang: codeLang) {
              HomePage(codeLang: codeLang, activity: activityClient.activity()?.redacted)
            }
          }
        case .pages(.notFound):
          let codeLang = CodeLang.resolve(req)
          return HTMLResponse {
            PageLayout(metadata: .default(), codeLang: codeLang) {
              NotFoundPage(codeLang: codeLang)
            }
          }
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

private struct NotFoundMiddleware<Context: RequestContext>: RouterMiddleware {
  func handle(
    _ request: Request,
    context: Context,
    next: (Request, Context) async throws -> Response
  ) async throws -> Response {
    do {
      return try await next(request, context)
    } catch let error as HTTPError {
      guard error.status == .notFound else {
        throw error
      }

      let codeLang = CodeLang.resolve(request)

      return try HTMLResponse {
        PageLayout(metadata: .default(), codeLang: codeLang) {
          NotFoundPage(codeLang: codeLang)
        }
      }
      .response(from: request, context: context)
    }
  }
}

extension PageMetadata {
  fileprivate static func `default`() -> Self {
    Self(
      title: "Erik Bautista Santibanez",
      description: "A software developer specialized in mobile and web applications.",
      image: GeneratedPublicAssets.publicAssets.assets.og.cardPng.path,
      url: "https://erikb.dev"
    )
  }
}

extension CodeLang {
  fileprivate static func resolve(_ req: Request) -> CodeLang {
    req.uri.queryParameters["codeLang"]
      .flatMap { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
      .flatMap(CodeLang.init(rawValue:)) ?? .markdown
  }
}
