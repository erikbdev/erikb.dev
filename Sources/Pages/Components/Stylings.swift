import ElementaryUI

extension HTML where Self: _Attributed, Tag: HTMLTrait.Attributes.Global {
  func wrappedStyling() -> Self {
    self.style("border-top", "1px solid #303030")
  }

  func containerStyling() -> Self {
    self.attributes(.class("auto-container"))
  }
}
