import Dependencies
import Elementary
import Hummingbird
import HummingbirdElementary
import HummingbirdRouter
import HummingbirdURLRouting
import MiddlewareUtils
import Pages
import Routes
import Models 

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
          return HTMLResponse {
            PageLayout(metadata: .default()) {
              HomePage(
                codeLang: .resolve(req),
                activity: activityClient.activity()?.redacted
              )
            }
          }
        case .pages(.notFound):
          return HTMLResponse {
            PageLayout(metadata: .default()) {
              NotFoundPage(codeLang: .resolve(req))
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
    _ input: Request,
    context: Context,
    next: (Request, Context) async throws -> Response
  ) async throws -> Response {
    do {
      return try await next(input, context)
    } catch let error as HTTPError {
      guard error.status == .notFound else {
        throw error
      }

      return try HTMLResponse {
        PageLayout(metadata: .default()) {
          NotFoundPage(codeLang: .resolve(input))
        }
      }
      .response(from: input, context: context)
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
