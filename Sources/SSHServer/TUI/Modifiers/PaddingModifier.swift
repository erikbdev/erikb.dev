struct PaddingModifier<Content: Component>: Component {
  let content: Content
  let edges: Edge.Set
  let length: Int

  func render() -> String {
    let value = content.render()
    let leading = String(repeating: " ", count: edges.values.contains(.leading) ? length : 0)
    let trailing = String(repeating: " ", count: edges.values.contains(.trailing) ? length : 0)
    let top = String(repeating: "\n", count: edges.values.contains(.top) ? length : 0)
    let bottom = String(repeating: "\n", count: edges.values.contains(.bottom) ? length : 0)
    return top + leading + value + trailing + bottom
  }
}

extension Component {
  func padding(_ edges: Edge.Set = .all, _ length: Int) -> some Component {
    PaddingModifier(content: self, edges: edges, length: length)
  }
}

enum Edge: Hashable {
  case top
  case bottom
  case leading
  case trailing

  struct Set {
    fileprivate let values: Swift.Set<Edge>

    static let all = Set(values: [.top, .bottom, .leading, .trailing])
    static let top = Set(values: [.top])
    static let bottom = Set(values: [.bottom])
    static let leading = Set(values: [.leading])
    static let trailing = Set(values: [.trailing])
    static let horizontal = Set(values: [.leading, .trailing])
    static let vertical = Set(values: [.top, .bottom])
  }
}
