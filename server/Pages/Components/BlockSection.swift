struct BlockSection<Content: HTML>: HTML {
  var fill: Bool
  var flush: Bool
  var extraClass: String
  var id: String?
  var content: Content

  init(
    fill: Bool = false,
    flush: Bool = false,
    extraClass: String = "",
    id: String? = nil,
    @HTMLBuilder content: () -> Content
  ) {
    self.fill = fill
    self.flush = flush
    self.extraClass = extraClass
    self.id = id
    self.content = content()
  }

  var body: some HTML {
    /* html */
    """
    <section \(attributes: ["id": id, "class": blockSectionClasses(fill: fill, flush: flush, extra: extraClass)])>\(content)</section>
    """
  }
}

struct NavBlockSection<Content: HTML>: HTML {
  var fill: Bool
  var flush: Bool
  var extraClass: String
  var content: Content

  init(
    fill: Bool = false,
    flush: Bool = false,
    extraClass: String = "",
    @HTMLBuilder content: () -> Content
  ) {
    self.fill = fill
    self.flush = flush
    self.extraClass = extraClass
    self.content = content()
  }

  var body: some HTML {
    /* html */
    """
    <nav class="\(blockSectionClasses(fill: fill, flush: flush, extra: extraClass))">\(content)</nav>
    """
  }
}

// A free function, since a static on the generic `BlockSection` can't be called from `NavBlockSection`
// without naming a `Content` type.
private func blockSectionClasses(fill: Bool, flush: Bool, extra: String) -> String {
  var c = "block-section"
  if fill { c += " block-section--fill" }
  if flush { c += " block-section--flush" }
  if !extra.isEmpty { c += " \(extra)" }
  return c
}
