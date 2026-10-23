import Hummingbird

struct HTMLResponse<Content: HTML>: ResponseGenerator {
  var status: HTTPResponse.Status
  var headers: HTTPFields
  var content: Content

  init(status: HTTPResponse.Status = .ok, headers: HTTPFields = [:], @HTMLBuilder content: () -> Content) {
    self.status = status
    self.headers = headers
    self.content = content()
  }

  func response(from request: Request, context: some RequestContext) throws -> Response {
    content.response(status: status, headers: headers)
  }
}

extension HTML {
  func response(status: HTTPResponse.Status = .ok, headers: HTTPFields = HTTPFields()) -> Response {
    var headers = headers
    headers[.contentType] = "text/html; charset=utf-8"
    var renderer = HTMLRenderer()
    self.render(into: &renderer)
    return Response(
      status: status,
      headers: headers,
      body: ResponseBody(byteBuffer: ByteBuffer(string: renderer.output))
    )
  }
}
