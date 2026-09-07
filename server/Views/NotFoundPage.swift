import Elementary
import HTTPTypes

struct NotFoundPage: HTML {
  var statusCode = HTTPResponse.Status.notFound

  var body: some HTML {
    Layout(pageTitle: "\(statusCode.code)") {
      BlockSection(id: "error") {
        header {
          a(.href("#error"), .class("whoami-prompt")) {
            span(.class("prompt-symbol")) { "$" }
            " cat error.md"
          }
        }

        section {
          h1(.class("page-title")) { "\(statusCode.code)" }
          p(.class("intro-text")) { 
            "The page or asset could not be found"
          }
          div(.class("link-row")) {
            a(.href("/"), .class("pill-link")) { "~/home" }
          }
        }
      }
    }
  }
}
