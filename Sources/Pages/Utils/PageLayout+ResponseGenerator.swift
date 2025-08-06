import HTML
import Hummingbird

extension PageLayout: ResponseGenerator {
  public consuming func response(
    from request: HummingbirdCore.Request,
    context: some Hummingbird.RequestContext
  ) -> HummingbirdCore.Response {
    self.response(from: request, context: context, status: .ok)
  }

  public consuming func response(
    from request: Request,
    context: some RequestContext,
    status: HTTPResponse.Status
  ) -> Response {
    Response(
      status: status,
      headers: [.contentType: "text/html; charset=utf-8"],
      body: ResponseBody { [self] writer in
        var htmlWriter = AsyncHTMLWriter(writer: &writer, chunkSize: 1024)
        try await self.render(into: &htmlWriter)
        try await htmlWriter.finish()
      }
    )
  }
}

private struct AsyncHTMLWriter: AsyncHTMLOutputStream {
  let writer: UnsafeMutablePointer<any ResponseBodyWriter>
  let chunkSize: Int

  let allocator = ByteBufferAllocator()
  var buffer: ByteBuffer

  init(
    writer: UnsafeMutablePointer<any ResponseBodyWriter>,
    chunkSize: Int
  ) {
    self.writer = writer
    self.chunkSize = chunkSize
    self.buffer = allocator.buffer(capacity: chunkSize + 512)
  }

  mutating func write(_ bytes: consuming some Sequence<UInt8>) async throws {
    buffer.writeBytes(bytes)

    if buffer.readableBytes >= chunkSize {
      try await writer.pointee.write(buffer)
      buffer.clear()
    }
  }

  mutating func finish() async throws {
    if buffer.readableBytes > 0 {
      try await writer.pointee.write(buffer)
    }
    try await writer.pointee.finish(nil)
    buffer.clear()
  }
}
