import CasePaths
import Dependencies
import Elementary
import Foundation
import Hummingbird
import HummingbirdElementary
import Shared
import URLRouting

struct HomePage: HTML {
  @Dependency(\.activityClient.activity) private var activity
  @Dependency(\.router) private var serverRouter
  @Dependency(\.currentRoute) private var currentRoute

  var body: some HTML {
    if currentRoute.is(\.page.index.activity) {
      ActivityComponent()
    } else {
      PageLayout {
        BlockSection(id: "user") {
          header {
            a(.href("#user"), .class("whoami-prompt")) {
              code {
                span(.class("prompt-symbol")) { "$" }
                " whoami"
              }
            }

            h1(.class("page-title")) { "Erik Bautista Santibanez" }

            p(.class("role-line")) { "Mobile & Web Developer" }

            div(.id("activity"), .hx.get(serverRouter.path(for: .page(.index(.activity)))), .hx.trigger(.every("10s"))) {
              ActivityComponent()
            }

            p(.class("intro-text")) {
              "I'm a passionate software developer who builds applications using Swift and modern web technologies."
            }

            div(.class("link-row")) {
              a(.href("mailto:me@erikb.dev"), .class(linkClass)) {
                code { "/me@erikb.dev" }
              }
              a(.href("/resume.pdf"), .custom(name: "target", value: "_blank"), .class(linkClass)) { code { "/resume.pdf" } }
              a(.href("https://github.com/erikbdev"), .custom(name: "target", value: "_blank"), .class(linkClass)) { code { "/github" } }
              a(.href("https://linkedin.com/in/erikbautista"), .custom(name: "target", value: "_blank"), .class(linkClass)) { code { "/linkedin" } }
            }
          }
        }

        Divider()

        BlockSection(flush: true) {
          header(.class("dev-logs-header")) {
            a(.href("#dev-logs"), .class("devlogs-prompt")) {
              code {
                span(.class("prompt-symbol")) { "$" }
                " ls -l /dev-logs/"
              }
            }
            h1(.class("devlogs-title")) { "Dev Logs" }
            p(.class("devlogs-subtitle")) { "A curated list of projects I've worked on." }
          }

          ForEach(Post.allCases) { post in
            article(.id(post.id), .class("log-entry")) {
              header {
                hgroup(.class("log-entry-meta")) {
                  a(.href("#\(post.id)")) {
                    code {
                      span(.class("prompt-symbol")) { "$" }
                      " cat log-\(post.index).md"
                    }
                  }
                  span(.class("log-entry-date")) { post.formattedDate }
                }
              }

              section(.class("log-entry-body")) {
                switch post.header {
                case let .code(lang, value):
                  pre {
                    code(.class("language-\(lang)")) {
                      value
                    }
                  }
                case let .image(src, label):
                  img(.src(src), .alt(label))
                case let .video(src, label):
                  video(
                    .src(src),
                    .title(label),
                    .custom(name: "autoplay", value: nil),
                    .custom(name: "playsinline"),
                    .custom(name: "muted"),
                    .custom(name: "loop")
                  )
                case .link, .none:
                  // og
                  EmptyHTML()
                }

                MarkdownHTML(markdown: post.content)
              }

              if !post.links.isEmpty {
                footer(.class("log-entry-links")) {
                  ForEach(post.links) { link in
                    a(.href(link.href), .class(linkClass)) { link.label }
                      .attributes(.custom(name: "target", value: "_blank"), when: !link.href.hasPrefix("/"))
                  }
                }
              }
            }
          }
        }

        Divider()
      }
    }
  }

  private var linkClass: String { "pill-link" }
}

extension ServerRoute.PageRoute {
  @CasePathable
  enum IndexRoute: Sendable, Equatable {
    case activity
  }
}

extension ServerRoute.PageRoute.IndexRoute {
  struct Router: Sendable, ParserPrinter {
    typealias IndexRoute = ServerRoute.PageRoute.IndexRoute

    init() {}

    var body: some URLRouting.Router<IndexRoute?> {
      OneOf {
        Route(.case(\.some) as AnyCasePath<IndexRoute?, IndexRoute>) {
          Path { "_components" }
          Route(.case(\.activity) as AnyCasePath<IndexRoute, Void>) {
            Path { "activity" }
          }
        }
        Route(.case(\.none) as AnyCasePath<IndexRoute?, Void>)
      }
    }
  }
}
