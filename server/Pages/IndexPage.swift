import CasePaths
import Dependencies
import Foundation
import Hummingbird
import Shared
import URLRouting

struct IndexPage: HTML {
  @Dependency(\.router) private var siteRouter
  @Dependency(\.currentRoute) private var currentRoute

  var body: some HTML {
    if currentRoute.is(\.page.index.activity) {
      ActivityComponent()
    } else {
      PageLayout {
        BlockSection(id: "user") {
          /* html */
          """
          <header>
            <a href="#user" class="whoami-prompt"><code><span class="prompt-symbol">$</span> whoami</code></a>
            <h1 class="page-title">Erik Bautista Santibanez</h1>
            <p class="role-line">Mobile &amp; Web Developer</p>
            <div id="activity" hx-get="\(siteRouter.path(for: .page(.index(.activity))))" hx-trigger="every 10s">
              \(ActivityComponent())
            </div>
            <p class="intro-text">I'm a passionate software developer who builds applications using Swift and modern web technologies.</p>
            <div class="link-row">
              <a href="mailto:me@erikb.dev" class="pill-link"><code>/me@erikb.dev</code></a>
              <a href="/resume.pdf" target="_blank" rel="noopener noreferrer" class="pill-link"><code>/resume.pdf</code></a>
              <a href="https://github.com/erikbdev" target="_blank" rel="noopener noreferrer" class="pill-link"><code>/github</code></a>
              <a href="https://linkedin.com/in/erikbautista" target="_blank" rel="noopener noreferrer" class="pill-link"><code>/linkedin</code></a>
            </div>
          </header>
          """
        }

        Divider()

        DevLogsSection()
      }
    }
  }
}

private struct DevLogsSection: HTML {
  static var styles: String {
    /* html */
    """
    <style>
      .dev-logs-header {
        padding: 2rem;
      }

      /* .devlogs-prompt { */
      /*   display: inline-block; */
      /*   font-size: 0.875rem; */
      /*   color: var(--color-white); */
      /*   margin-bottom: 1.25rem; */
      /* } */

      .devlogs-title {
        font-size: 1.875rem;
        font-weight: 700;
        margin-bottom: 0.375rem;
        color: var(--color-white);
      }

      .devlogs-subtitle {
        color: var(--color-neutral-300);
      }

      .log-entry {
        padding: 2rem;
        border-top: var(--size-gridline) dashed var(--color-gridline);
      }

      .log-entry-meta {
        width: 100%;
        font-size: 0.875rem;
        margin-bottom: 1.5rem;
        color: var(--color-white);
        display: flex;
        flex-direction: row;
        justify-content: space-between;
        align-items: center;
      }

      .log-entry-date {
        color: var(--color-neutral-700);
      }

      .log-entry-links {
        margin-top: 1.5rem;
        display: flex;
        flex-direction: row;
        flex-wrap: wrap;
        gap: 0.5rem;
        font-weight: 500;
      }

      /* Markdown post body ("prose") */

      .log-entry-body {
        width: 100%;
        max-width: none;
        margin-top: 0.75rem;
        line-height: 1.75;
      }

      .log-entry-body :where(p) {
        margin-block: 1em;
        color: var(--color-neutral-300);
      }

      .log-entry-body :where(h1, h2, h3, h4, h5, h6) {
        font-size: 1.25rem;
        line-height: 1.4;
        font-weight: 700;
        color: var(--color-white);
        margin-top: 1.6em;
        margin-bottom: 0.6em;
      }

      .log-entry-body :where(a) {
        color: var(--color-white);
        font-weight: 500;
        text-decoration: underline;
      }

      .log-entry-body :where(strong) {
        color: var(--color-white);
        font-weight: 600;
      }

      .log-entry-body :where(ul, ol) {
        margin-block: 1em;
        padding-inline-start: 1.625em;
        color: var(--color-neutral-300);
      }

      .log-entry-body :where(ul) {
        list-style-type: disc;
      }

      .log-entry-body :where(ol) {
        list-style-type: decimal;
      }

      .log-entry-body :where(li) {
        margin-block: 0.5em;
      }

      .log-entry-body :where(blockquote) {
        border-inline-start: 0.25rem solid var(--color-gridline);
        padding-inline-start: 1em;
        font-style: italic;
        color: var(--color-neutral-300);
      }

      .log-entry-body :where(code) {
        font-weight: 600;
        color: var(--color-white);
      }

      .log-entry-body :where(code)::before,
      .log-entry-body :where(code)::after {
        content: "`";
      }

      .log-entry-body :where(pre) {
        background-color: #141414;
        color: var(--color-neutral-300);
        padding: 0.857em 1.143em;
        border-radius: 0.375rem;
        margin-block: 1.7em;
        overflow-x: auto;
      }

      .log-entry-body :where(pre code) {
        font-weight: inherit;
        background-color: transparent;
        padding: 0;
      }

      .log-entry-body :where(pre code)::before,
      .log-entry-body :where(pre code)::after {
        content: none;
      }

      .log-entry-body :where(img, video) {
        margin-block: 2em;
      }

      .log-entry-body :where(hr) {
        border-top: var(--size-gridline) solid var(--color-gridline);
        margin-block: 3em;
      }
    </style>
    """
  }

  var body: some HTML {
    BlockSection(flush: true) {
      /* html */
      """
      <header class="dev-logs-header">
        <a href="#dev-logs" class="devlogs-prompt">\(CommandPromptComponent(command: "ls -l /dev-logs/"))</a>
        <h1 class="devlogs-title">Dev Logs</h1>
        <p class="devlogs-subtitle">A curated list of projects I've worked on.</p>
      </header>
      """

      for post in Post.allCases {
        /* html */
        """
        <article id="\(post.id)" class="log-entry">
          <header>
            <hgroup class="log-entry-meta">
              <a href="#\(post.id)"><code><span class="prompt-symbol">$</span> cat log-\(post.index).md</code></a>
              <span class="log-entry-date">\(post.formattedDate)</span>
            </hgroup>
          </header>
          <section class="log-entry-body">
            \({
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
                HTMLString()
              }
            })
            \(MarkdownHTML(markdown: post.content))
          </section>
          \({
            if !post.links.isEmpty {
              /* html */
              """
              <footer class="log-entry-links">
                \({
                  for link in post.links {
                    if link.href.hasPrefix("/") {
                      /* html */
                      """
                      <a href="\(link.href)" class="pill-link">\(link.label)</a>
                      """
                    } else {
                      /* html */
                      """
                      <a href="\(link.href)" class="pill-link" target="_blank" rel="noopener noreferrer">\(link.label)</a>
                      """
                    }
                  }
                })
              </footer>
              """
            }
          })
        </article>
        """
      }
    }
  }
}

extension SiteRoute.PageRoute {
  @CasePathable
  enum IndexRoute: Sendable, Equatable {
    case activity
  }
}

extension SiteRoute.PageRoute.IndexRoute {
  struct Router: Sendable, ParserPrinter {
    typealias IndexRoute = SiteRoute.PageRoute.IndexRoute

    init() {}

    var body: some URLRouting.Router<IndexRoute?> {
      OneOf {
        Route(.case(\.activity) as AnyCasePath<IndexRoute?, Void>) {
          Headers {
            Field("HX-Request") { "true" }
            Field("HX-Source") { "div#activity" }
          }
        }
        Route(.case(\.none) as AnyCasePath<IndexRoute?, Void>)
      }
    }
  }
}
