struct Text: Component {
  let text: String

  init(_ text: String) {
    self.text = text
  }

  func render() -> String {
    text
  }
}
