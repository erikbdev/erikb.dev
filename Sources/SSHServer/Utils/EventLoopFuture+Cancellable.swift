import NIOCore

extension EventLoopFuture {
  func cancellableGet() async throws -> Value where Value: Sendable {
    let promise = eventLoop.makePromise(of: Value.self)
    self.cascade(to: promise)
    return try await withTaskCancellationHandler {
      return try await promise.futureResult.get()
    } onCancel: {
      promise.fail(CancellationError())
    }
  }
}