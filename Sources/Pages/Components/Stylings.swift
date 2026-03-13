import ElementaryUI

extension HTML where Tag: HTMLTrait.Attributes.Global {
  func wrappedStyling() -> _AttributedElement<Self> {
    self.style("border-top", "1px solid #303030")
  }

  func containerStyling() -> _AttributedElement<Self> {
    self.style(
      [
        "max-width": "40rem",
        "margin-right": "auto",
        "margin-left": "auto",
        "border-left": "1px solid #303030",
        "border-right": "1px solid #303030"
      ]
    )
    // self.inlineStyle("max-width", "40rem", media: .minWidth(712))
    //   .inlineStyle("margin-right", "auto")
    //   .inlineStyle("margin-left", "auto")
    //   .inlineStyle("border-left", "1px solid #303030", media: .minWidth(640))
    //   .inlineStyle("border-right", "1px solid #303030", media: .minWidth(640))
  }
}
