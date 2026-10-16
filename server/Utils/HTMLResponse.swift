import Hummingbird

struct HTMLResponse: ResponseGenerator {
  var status: HTTPResponse.Status = .ok
  var headers: HTTPFields = [:]
  @HTML.Builder var content: HTML

  func response(from request: Request, context: some RequestContext) throws -> Response {
    var headers = headers
    headers[.contentType] = headers[.contentType] ?? "text/html; charset=utf-8"
    return Response(
      status: status,
      headers: headers,
      body: ResponseBody(byteBuffer: ByteBuffer(string: content.rawValue))
    )
  }
}
