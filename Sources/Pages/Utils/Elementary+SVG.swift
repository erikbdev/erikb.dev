import ElementaryUI

extension HTMLAttribute where Tag == HTMLTag.svg {
  static func xmlns() -> Self {
    Self(name: "xmlns", value: "http://www.w3.org/2000/svg")
  }

  static func fill(_ color: String?) -> Self {
    Self(name: "fill", value: color)
  }

  static func viewBox(_ size: String?) -> Self {
    Self(name: "viewBox", value: size)
  }
}

extension HTMLTag {
  enum path: HTMLTrait.Unpaired { static let name = "path" }
}

extension HTMLAttribute where Tag == HTMLTag.path {
  static func d(_ data: String?) -> Self {
    Self(name: "d", value: data)
  }
}

typealias path = HTMLVoidElement<HTMLTag.path>