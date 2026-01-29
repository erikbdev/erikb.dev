protocol Component {
  associatedtype Body

  func render() -> String

  @ComponentBuilder
  var body: Body { get }
}

extension Component where Body == Never { 
  var body: Never { fatalError("Tried accessing \(Self.self).body of type Never") }
}

extension Component where Body: Component {
  func render() -> String {
    self.body.render()
  }
}
