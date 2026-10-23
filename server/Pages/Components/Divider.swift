struct Divider: HTML {
  static var styles: String {
    /* html */
    """
    <style>
      .block-section-divider {
        position: relative;
        height: 1rem;
        width: 100vw;
        left: 0;
        background-color: var(--color-base);
        border-top: var(--size-gridline) solid;
        border-color: var(--color-gridline);

        box-shadow:
          -1px 0 0 0 inset var(--color-gridline),
          1px 0 0 0 inset var(--color-gridline);
        border-image: linear-gradient(to right, var(--color-gridline), var(--color-gridline)) 1 / 1px 0 0 0 / 0 100vw 0 100vw;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='8' height='8'%3E%3Cpath d='M0 8L8 0M-2 2L2-2M6 10L10 6' stroke='%231c1c1c' stroke-width='2' stroke-linecap='square'/%3E%3C/svg%3E");
        background-size: 6px 4px;
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
    <hr class="block-section-divider">
    """
  }
}
