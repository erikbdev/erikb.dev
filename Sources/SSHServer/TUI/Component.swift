protocol Component {
  associatedtype Body

  @ComponentBuilder
  var body: Body { get }

  func render(into renderer: inout VTBuffer) 
}

extension Component where Body == Never { 
  var body: Never { fatalError("Tried accessing \(Self.self).body of type Never") }
}

extension Component where Body: Component {
  func render(into renderer: inout VTBuffer) {
    self.body.render(into: &renderer)
  }
}

