struct PaddingModifier<Content: Component>: _PrimitiveComponent {
  let content: Content
}

extension Component {
  func padding(_ edges: Edge.Set = .all, _ length: Int) -> some Component {
    PaddingModifier(content: self)
  }
}

enum Edge: Hashable {
  case top
  case bottom
  case leading
  case trailing

  struct Set {
    private var values = Swift.Set<Edge>()

    static let all = Set(values: [.top, .bottom, .leading, .trailing])
    static let top = Set(values: [.top])
    static let bottom = Set(values: [.bottom])
    static let leading = Set(values: [.leading])
    static let trailing = Set(values: [.trailing])
    static let horizontal = Set(values: [.leading, .trailing])
    static let vertical = Set(values: [.top, .bottom])
  }
}