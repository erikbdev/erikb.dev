import Foundation
import Hummingbird
import HummingbirdElementary
import NIOCore

struct PublicFilesMiddleware<Context: RequestContext>: RouterMiddleware {
  private var _fileMiddleware: FileMiddleware<Context, LocalFileSystem>

  private static var publicPath: String { "public" }

  init() {
    self._fileMiddleware = FileMiddleware(Self.publicPath, searchForIndexHtml: true)
  }

  func handle(_ request: Request, context: Context, next: (Request, Context) async throws -> Response) async throws -> Response {
    do {
      return try await _fileMiddleware.handle(request, context: context, next: next)
    } catch {
      guard let httpError = error as? HTTPResponseError, httpError.status == .notFound else {
        throw error
      }
      guard request.method == .get || request.method == .head else {
        throw error
      }
      guard let accept: String = request.headers[.accept], accept.contains("text/html") || accept.contains("*/*") || accept.contains("text/*") else {
        throw error
      }

      return HTMLResponse(status: httpError.status) {
        NotFoundPage(statusCode: httpError.status)
      }
      .response(from: request, context: context)
    }
  }
}
