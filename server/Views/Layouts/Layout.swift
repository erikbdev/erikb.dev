import Dependencies
import Elementary
import Foundation


#if DEBUG
  let buildTimestamp = Date().formatted(.iso8601) 
#endif

struct Layout<Content: HTML>: HTML {
  var pageTitle: String? = nil
  @HTMLBuilder var content: Content

  @Dependency(\.siteRouter) private var router

  private var resolvedTitle: String {
    return [pageTitle ?? "","erikb.dev"].filter { !$0.isEmpty }
      .joined(separator: " | ")
  }

  private var copyrightYear: String {
    String(Calendar(identifier: .gregorian).component(.year, from: Date()))
  }

  var body: some HTML {
    HTMLRaw("<!DOCTYPE html>")
    html(.data("theme", value: "dark")) {
      head {
        meta(.charset(.utf8))
        meta(.name(.viewport), .content("width=device-width, initial-scale=1.0, viewport-fit=cover"))
        title { resolvedTitle }
        link(.rel(.icon), .href("/favicon-16x16.png"), .custom(name: "type", value: "image/png"), .custom(name: "sizes", value: "16x16"))
        link(.rel(.icon), .href("/favicon-32x32.png"), .custom(name: "type", value: "image/png"), .custom(name: "sizes", value: "32x32"))
        link(.rel(.icon), .href("/favicon-96x96.png"), .custom(name: "type", value: "image/png"), .custom(name: "sizes", value: "96x96"))
        link(.rel(.icon), .href("/favicon-128x128.png"), .custom(name: "type", value: "image/png"), .custom(name: "sizes", value: "128x128"))
        link(.rel(.stylesheet), .href("/styles/site.css"))
        script(.src("/scripts/vendors/htmx.min.js"))
      }
      Elementary.body(.class("site-body")) {
        header(.class("site-header")) {
          BlockSection(divider: false, extraClass: "terminal-banner") {
            "TERM xterm-256color · TTY0 · connection opened"
          }
          NavBlockSection(divider: false, extraClass: "site-nav") {
            a(.href("/"), .class("brand-link")) {
              span(.class("brand-text")) {
                "erikb@dev:~"
                span(.class("prompt-symbol")) { "$" }
              }
            }
          }
        }
        content
        footer {
          BlockSection(divider: false, extraClass: "site-footer-copyright") {
            "© \(copyrightYear) erikb.dev"
          }
          BlockSection(divider: false, extraClass: "site-footer-status") {
            "connection closed."
          }
        }

        #if DEBUG
          // Live reload
          div(
            .hidden, 
            .hx.get(router.path(for: .api(.liveReload(build: buildTimestamp)))),
            .hx.trigger(.every("2s")),
            .hx.swap(.none),
          )
        #endif
      }
    }
  }
}
