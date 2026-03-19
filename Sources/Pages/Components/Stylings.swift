import ElementaryUI

extension HTML where Tag: HTMLTrait.Attributes.Global {
  func wrappedStyling() -> _AttributedElement<Self> {
    self.style("border-top", "1px solid #303030")
  }

  func containerStyling() -> _AttributedElement<Self> {
    self.attributes(.class("auto-container"))
  }
}
