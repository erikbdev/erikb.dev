import ElementaryUI

extension _AttributedElement where Tag: HTMLTrait.Attributes.Global {
  func style(_ name: String, _ value: String) -> Self { 
    self.attributes(.style([name: value]))
  }

  func style(_ nameValuePair: KeyValuePairs<String, String>) -> Self {
    self.attributes(.style(nameValuePair))
  }
}

extension HTML where Tag: HTMLTrait.Attributes.Global {
  @_disfavoredOverload
  func style(_ name: String, _ value: String) -> _AttributedElement<Self> { 
    self.attributes(.style([name: value]))
  }

  @_disfavoredOverload
  func style(_ nameValuePair: KeyValuePairs<String, String>) -> _AttributedElement<Self> {
    self.attributes(.style(nameValuePair))
  }
}