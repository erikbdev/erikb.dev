import Hummingbird

extension HTML: ResponseGenerator {
  public func response(from request: Request, context: some RequestContext) throws -> Response {
    Response(
      status: .ok,
      headers: [.contentType: "text/html; charset=utf-8"],
      body: ResponseBody(byteBuffer: ByteBuffer(string: rawValue))
    )
  }
}
