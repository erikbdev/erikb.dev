import ElementaryUI

extension HTML where Self: _Attributed, Tag: HTMLTrait.Attributes.Global {
  func style(_ name: String, _ value: String, condition: Bool = true) -> Self {
    if condition {
      self.attributes(.style([name: value]))
    } else {
      self
    }
  }

  func style(_ nameValuePair: KeyValuePairs<String, String>, condition: Bool = true) -> Self {
    if condition {
      self.attributes(.style(nameValuePair))
    } else {
      self
    }
  }
}
