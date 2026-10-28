struct BlockSection<Content: HTML>: HTML {
  var tag: String
  var fill: Bool
  var flush: Bool
  var extraClass: String
  var id: String?
  var content: Content

  init(
    tag: String = "section",
    fill: Bool = false,
    flush: Bool = false,
    extraClass: String = "",
    id: String? = nil,
    @HTMLBuilder content: () -> Content
  ) {
    self.tag = tag
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
        background-color: var(--color-base);
        width: 100%;
      }

      .block-section:not([data-fill]) {
        border-inline: var(--size-gridline) solid var(--color-gridline);
        max-width: var(--content-max-width);
        margin-inline: auto;
        padding: var(--section-padding);
      }

      @media (max-width: 47.9375rem) {
        .block-section:not([data-fill]) {
          border-inline: 0;
        }
      }

      .block-section[data-flush] {
        padding: 0 !important;
      }
    </style>
    """
  }

  var body: some HTML {
    /* html */
    """
    <\(unsafe: tag) \(attributes: ["id": id, "class": "block-section \(extraClass)", "data-fill": fill ? "" : nil, "data-flush": flush ? "" : nil])>\(content)</\(unsafe: tag)>
    """
  }
}
