struct Text: _PrimitiveComponent {
  let text: String

  init(_ text: String) {
    self.text = text
  }

  var body: Never { fatalError() }
}