struct BlockSection: HTML.Component {
  var fill: Bool = false
  var flush: Bool = false
  var extraClass: String = ""
  var id: String?
  @HTML.Builder var content: HTML

  var body: HTML {
    if let id {
      /* html */ """
      <section id="\(id)" class="\(Self.classes(fill: fill, flush: flush, extra: extraClass))">\(content)</section>
      """
    } else {
      /* html */ """
      <section class="\(Self.classes(fill: fill, flush: flush, extra: extraClass))">\(content)</section>
      """
    }
  }

  static func classes(fill: Bool, flush: Bool, extra: String) -> String {
    var c = "block-section"
    if fill { c += " block-section--fill" }
    if flush { c += " block-section--flush" }
    if !extra.isEmpty { c += " \(extra)" }
    return c
  }
}

struct NavBlockSection: HTML.Component {
  var fill: Bool = false
  var flush: Bool = false
  var extraClass: String = ""
  @HTML.Builder var content: HTML

  var body: HTML {
    /* html */ """
    <nav class="\(BlockSection.classes(fill: fill, flush: flush, extra: extraClass))">\(content)</nav>
    """
  }
}

struct Divider: HTML.Component {
  var body: HTML {
    /* html */ """
    <section class="block-section-divider"></section>
    """
  }
}
