import ElementaryUI

public protocol Page: HTML, View {
  var title: String { get }
}
