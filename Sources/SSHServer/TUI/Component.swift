protocol Component {
  associatedtype Body: Component
  var body: Body { get }
}

extension Never: Component { 
  var body: Never { fatalError("Tried accessing `body` of type Never") }
}

protocol _PrimitiveComponent: Component where Body == Never {}

extension _PrimitiveComponent { 
  var body: Never { fatalError("Tried accessing \(Self.self).body of type Never") }
}
