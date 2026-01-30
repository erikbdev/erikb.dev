@resultBuilder
enum CellBuilder {
  static func buildBlock() -> EmptyCell {
    EmptyCell()
  }

  static func buildBlock<C: Cell>(_ component: C) -> C {
    component
  }

  @_disfavoredOverload
  static func buildBlock<each C: Cell>(_ components: repeat each C) -> TupleComponent<repeat each C> {
    TupleComponent(content: (repeat each components))
  }


  static func buildEither<T: Cell, F: Cell>(first component: T) -> _ConditionalComponent<T, F> {
    .trueComponent(component)
  }
  
  static func buildEither<T: Cell, F: Cell>(second component: F) -> _ConditionalComponent<T, F> {
    .falseComponent(component)
  }
}

struct TupleComponent<each C: Cell>: Cell {
  let content: (repeat each C)

  func render() -> String {
    var result = ""
    (repeat result.append((each content).render()))
    return result
  }
}

enum _ConditionalComponent<T: Cell, F: Cell>: Cell {
  case trueComponent(T)
  case falseComponent(F)

  func render() -> String {
    switch self {
    case .trueComponent(let c): c.render()
    case .falseComponent(let c): c.render()
    }
  }
}
