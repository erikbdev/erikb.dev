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

  static var styles: String {
    /* html */
    """
    <style>
      .block-section {
        position: relative;
        background-color: var(--color-base);
        border-color: var(--color-gridline);
        width: 100%;
      }

      .block-section > * {
        position: relative;
      }

      .block-section::before {
        content: "";
        z-index: -1;
        background-color: inherit;
        position: absolute;
        width: 100vw;
        top: -0.8px;
        left: 50%;
        transform: translateX(-50%);
        border-top: var(--size-gridline) solid;
        border-color: inherit;
        bottom: 0;
      }

      .block-section:not(.block-section--fill) {
        border-inline: var(--size-gridline) solid var(--color-gridline);
        max-width: var(--content-max-width);
        margin-inline: auto;
        padding: var(--section-padding);
      }

      @media (max-width: 47.9375rem) {
        .block-section:not(.block-section--fill) {
          border-inline: 0;
        }
      }

      .block-section--flush {
        padding: 0 !important;
      }
    </style>
    """
  }

  var body: some HTML {
    /* html */
    """
    <section \(attributes: ["id": id, "class": blockSectionClasses(fill: fill, flush: flush, extra: extraClass)])>\(content)</section>
    """
  }
}

/// Uses `BlockSection`'s classes; their styles come from `BlockSection`, which the layout footer always renders.
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
