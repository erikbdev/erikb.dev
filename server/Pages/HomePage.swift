import CasePaths
import Dependencies
import Foundation
import Hummingbird
import Shared
import URLRouting

struct HomePage: HTML.Component {
  @Dependency(\.activityClient.activity) private var activity
  @Dependency(\.router) private var serverRouter
  @Dependency(\.currentRoute) private var currentRoute

  var body: HTML {
    if currentRoute.is(\.page.index.activity) {
      ActivityComponent()
    } else {
      PageLayout {
        BlockSection(id: "user") {
          /* html */ """
          <header>
            <a href="#user" class="whoami-prompt"><code><span class="prompt-symbol">$</span> whoami</code></a>
            <h1 class="page-title">Erik Bautista Santibanez</h1>
            <p class="role-line">Mobile &amp; Web Developer</p>
            <div id="activity" hx-get="\(serverRouter.path(for: .page(.index(.activity))))" hx-trigger="every 10s">\(ActivityComponent())</div>
            <p class="intro-text">I'm a passionate software developer who builds applications using Swift and modern web technologies.</p>
            <div class="link-row">
              <a href="mailto:me@erikb.dev" class="pill-link"><code>/me@erikb.dev</code></a>
              <a href="/resume.pdf" target="_blank" class="pill-link"><code>/resume.pdf</code></a>
              <a href="https://github.com/erikbdev" target="_blank" class="pill-link"><code>/github</code></a>
              <a href="https://linkedin.com/in/erikbautista" target="_blank" class="pill-link"><code>/linkedin</code></a>
            </div>
          </header>
          """
        }

        Divider()

        BlockSection(flush: true) {
          /* html */ """
          <header class="dev-logs-header">
            <a href="#dev-logs" class="devlogs-prompt"><code><span class="prompt-symbol">$</span> ls -l /dev-logs/</code></a>
            <h1 class="devlogs-title">Dev Logs</h1>
            <p class="devlogs-subtitle">A curated list of projects I've worked on.</p>
          </header>
          """

          for post in Post.allCases {
            /* html */ """
            <article id="\(post.id)" class="log-entry">
              <header>
                <hgroup class="log-entry-meta">
                  <a href="#\(post.id)"><code><span class="prompt-symbol">$</span> cat log-\(post.index).md</code></a>
                  <span class="log-entry-date">\(post.formattedDate)</span>
                </hgroup>
              </header>
              <section class="log-entry-body">
            """

            switch post.header {
            case let .code(lang, value):
              /* html */
              """
              <pre><code class="language-\(lang)">\(value)</code></pre>
              """
            case let .image(src, label):
              /* html */
              """
              <img src="\(src)" alt="\(label)">
              """
            case let .video(src, label):
              /* html */
              """
              <video src="\(src)" title="\(label)" autoplay playsinline muted loop></video>
              """
            case .link, .none:
              HTML()
            }

            MarkdownHTML(markdown: post.content)

            /* html */ "</section>"

            if !post.links.isEmpty {
              /* html */ """
              <footer class="log-entry-links">
              """

              for link in post.links {
                if link.href.hasPrefix("/") {
                  /* html */ """
                  <a href="\(link.href)" class="pill-link">\(link.label)</a>
                  """
                } else {
                  /* html */ """
                  <a href="\(link.href)" class="pill-link" target="_blank">\(link.label)</a>
                  """
                }
              }

              /* html */
              "</footer>"
            }

            /* html */
            "</article>"
          }
        }

        Divider()
      }
    }
  }
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
