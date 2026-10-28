struct Divider: HTML {
  enum Style {
    /// A hatched spacer with a full-width line on each edge. Purely decorative.
    case hatched
    /// A single full-width line.
    case line
  }

  var style: Style

  init(_ style: Style = .hatched) {
    self.style = style
  }

  static var styles: String {
    /* html */
    """
    <style>
      .block-section-divider {
        height: 1rem;
        background-color: var(--color-base);
        border-block: var(--size-gridline) solid;
        /* Extends the top/bottom lines to the viewport edges, past the content width. */
        border-image: linear-gradient(var(--color-gridline), var(--color-gridline)) 1 / 1 / 0 100vw;

        box-shadow:
          -1px 0 0 0 inset var(--color-gridline),
          1px 0 0 0 inset var(--color-gridline);
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='8' height='8'%3E%3Cpath d='M0 8L8 0M-2 2L2-2M6 10L10 6' stroke='%231c1c1c' stroke-width='2' stroke-linecap='square'/%3E%3C/svg%3E");
        background-size: 6px 4px;
      }

      .block-section-divider[data-line] {
        height: 0;
        border-bottom-width: 0;
        background: none;
        box-shadow: none;
      }

      @media (min-width: 48rem) {
        .block-section-divider {
          max-width: var(--content-max-width);
          margin-inline: auto;
        }
      }
    </style>
    """
  }

  var body: some HTML {
    /* html */
    """
    <hr \(attributes: ["class": "block-section-divider", "aria-hidden": style == .hatched ? "true" : nil, "data-line": style == .line ? "" : nil])>
    """
  }
}
