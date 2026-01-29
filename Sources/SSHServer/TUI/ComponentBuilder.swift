@resultBuilder
enum ComponentBuilder {
  static func buildBlock() -> EmptyComponent {
    EmptyComponent()
  }

  static func buildBlock<C: Component>(_ component: C) -> C {
    component
  }

  @_disfavoredOverload
  static func buildBlock<each C: Component>(_ components: repeat each C) -> TupleComponent<repeat each C> {
    TupleComponent(content: (repeat each components))
  }


  static func buildEither<T: Component, F: Component>(first component: T) -> _ConditionalComponent<T, F> {
    .trueComponent(component)
  }
  
  static func buildEither<T: Component, F: Component>(second component: F) -> _ConditionalComponent<T, F> {
    .falseComponent(component)
  }
}

struct TupleComponent<each C: Component>: Component {
  let content: (repeat each C)

  func render() -> String {
    var result = ""
    (repeat result.append((each content).render()))
    return result
  }
}

enum _ConditionalComponent<T: Component, F: Component>: Component {
  case trueComponent(T)
  case falseComponent(F)

  func render() -> String {
    switch self {
    case .trueComponent(let c): c.render()
    case .falseComponent(let c): c.render()
    }
  }
}
