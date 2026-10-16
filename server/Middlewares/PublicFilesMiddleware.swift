import Foundation
import Hummingbird
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

      var response = try NotFoundPage(statusCode: httpError.status).body.response(from: request, context: context)
      response.status = httpError.status
      return response
    }
  }
}
