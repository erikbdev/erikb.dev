protocol Cell {
  associatedtype Body

  func render() -> String

  @CellBuilder
  var body: Body { get }
}

extension Cell where Body == Never { 
  var body: Never { fatalError("Tried accessing \(Self.self).body of type Never") }
}

extension Cell where Body: Cell {
  func render() -> String {
    self.body.render()
  }
}

struct CellShape {
  // ANSI SGR
  var style = Style()
  // let link: Link
  // let comb: [Rune]
  // let width: Int
  // let rune: Rune

  struct Style {
    var values = [String]()

    func render() -> String {
      "\\x1b[\(values.joined(separator: ";"))m"
    }
  }
}