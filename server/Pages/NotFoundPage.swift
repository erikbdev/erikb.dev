import HTTPTypes

struct NotFoundPage: HTML.Component {
  var statusCode = HTTPResponse.Status.notFound

  var body: HTML {
    PageLayout(pageTitle: "\(statusCode.code)") {
      BlockSection(id: "error") {
        /* html */
        """
        <header>
          <a href="#error" class="whoami-prompt"><span class="prompt-symbol">$</span> cat error.md</a>
        </header>
        <section>
          <h1 class="page-title">\(statusCode.code)</h1>
          <p class="intro-text">The page or asset could not be found</p>
          <div class="link-row">
            <a href="/" class="pill-link">~/home</a>
          </div>
        </section>
        """
      }

      Divider()
    }
  }
}
