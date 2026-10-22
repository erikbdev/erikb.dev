import Hummingbird

struct HTMLResponse: ResponseGenerator {
  var status: HTTPResponse.Status = .ok
  var headers: HTTPFields = [:]
  @HTML var content: HTML

  func response(from request: Request, context: some RequestContext) throws -> Response {
    content.response(status: status, headers: headers)
  }
}

extension HTML.Component {
  func response(status: HTTPResponse.Status = .ok, headers: HTTPFields = HTTPFields()) -> Response {
    var headers = headers
    headers[.contentType] = "text/html; charset=utf-8"
    return Response(
      status: status,
      headers: headers,
      body: ResponseBody(byteBuffer: ByteBuffer(string: self.body.rawValue))
    )
  }
}
