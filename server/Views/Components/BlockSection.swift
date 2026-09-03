import Elementary

struct BlockSection<Content: HTML>: HTML {
  var divider: Bool = true
  var fill: Bool = false
  var flush: Bool = false
  var extraClass: String = ""
  var id: String?
  @HTMLBuilder var content: Content

  var body: some HTML {
    section(.class(Self.classes(divider: divider, fill: fill, flush: flush, extra: extraClass))) {
      content
    }
    .attributes(.id(id ?? ""), when: id != nil)
  }

  static func classes(divider: Bool, fill: Bool, flush: Bool, extra: String) -> String {
    var c = "block-section"
    if fill { c += " block-section--fill" }
    if divider { c += " block-section--divider" }
    if flush { c += " block-section--flush" }
    if !extra.isEmpty { c += " \(extra)" }
    return c
  }
}

struct NavBlockSection<Content: HTML>: HTML {
  var divider: Bool = true
  var fill: Bool = false
  var flush: Bool = false
  var extraClass: String = ""
  @HTMLBuilder var content: Content

  var body: some HTML {
    nav(.class(BlockSection<Content>.classes(divider: divider, fill: fill, flush: flush, extra: extraClass))) {
      content
    }
  }
}
