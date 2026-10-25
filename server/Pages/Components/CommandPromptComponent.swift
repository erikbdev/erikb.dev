struct CommandPromptComponent: HTML {
  var showHostname = false
  var command: String?

  static let styles = /* html */ """
    <style>
      .prompt-line {
        display: inline-block;
        color: var(--color-neutral-100);
        font-weight: 700;
        font-size: 0.875rem;
      }
      .prompt-symbol {
        color: var(--color-terminal);
      }
    </style>
    """

  var body: some HTML {
    /* html */
    """
    <code class="prompt-line">
      \({ showHostname ? "erikb@dev:~" : ""})<span class="prompt-symbol">$</span>
      \(command ?? "")
    </code>
    """
  }
}
