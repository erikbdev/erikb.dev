final class AnyCancellable: @unchecked Sendable {
  var _cancel: (() -> Void)?

  init(_ cancel: @escaping () -> Void) {
    self._cancel = cancel
  }

  func cancel() {
    _cancel?()
    _cancel = nil
  }

  deinit {
    _cancel?()
  }
}
