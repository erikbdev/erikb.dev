import HTML

extension HTML {
  func svgIconStyling() -> HTMLInlineStyle<Self> {
    self.inlineStyle("display", "inline-block")
      .inlineStyle("vertical-align", "middle")
      .inlineStyle("position", "relative")
      .inlineStyle("bottom", "0.125em")
      .inlineStyle("width", "1em")
      .inlineStyle("height", "1em")
  }
}