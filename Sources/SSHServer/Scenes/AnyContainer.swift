import TauTUI

protocol AnyContainer: Component {
  var children: [Component] { get set }

  func addChild(_ child: Component)
  func removeChild(_ child: Component)
  func clear()
  func invalidate()
  func render(width: Int) -> [String]
}

extension AnyContainer {
  func addChild(_ child: Component) {
    self.children.append(child)
  }

  func removeChild(_ child: Component) {
    guard let index = children.firstIndex(where: { $0 === child }) else {
      return
    }
    self.children.remove(at: index)
  }

  func clear() {
    self.children.removeAll()
  }

  func invalidate() {
    self.children.forEach { $0.invalidate() }
  }

  func render(width: Int) -> [String] {
    self.children.flatMap { $0.render(width: width) }
  }
}