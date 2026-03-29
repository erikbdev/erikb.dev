import ElementaryUI

extension HTML where Self: _Attributed, Tag: HTMLTrait.Attributes.Global {
  func svgIconStyling() -> Self {
    self.style([
      "display": "inline-block",
      "vertical-align": "middle",
      "position": "relative",
      "bottom": "0.125em",
      "width": "1em",
      "height": "1em"
    ])
  }
}
