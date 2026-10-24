struct CommandPromptComponent: HTML {
  var showHostname = false
  var command: String?

  static let styles = /* html */ """
    <style>
      .prompt-line {
        display: inline-block;
        color: var(--color-white);
      }
      .prompt-symbol {
          color: var(--color-terminal);
      }
      .prompt-command {
      }
    </style>
    """

  var body: some HTML {
    /* html */
    """
    <code="">
      \({
        if showHostname {
          "erikb@dev:~"
        }
      })
      <span class="prompt-symbol">$</span>
      \(command ?? "")
    </code>
    """
  }
}
