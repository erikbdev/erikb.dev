import Foundation
import Hummingbird
import NIOCore

struct NotFoundMiddleware<Context: RequestContext>: RouterMiddleware {
  func handle(_ request: Request, context: Context, next: (Request, Context) async throws -> Response) async throws -> Response {
    do {
      return try await next(request, context)
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

      return try HTMLResponse(status: httpError.status) {
        NotFoundPage(statusCode: httpError.status)
      }
      .response(from: request, context: context)
    }
  }
}
