import Dependencies
import Foundation

#if DEBUG
  let buildTimestamp = Date().formatted(.iso8601)
#endif

struct PageLayout<Content: HTML>: HTML {
  @Dependency(\.router) private var router

  var title: String? = nil
  var content: Content

  init(title: String? = nil, @HTMLBuilder content: () -> Content) {
    self.title = title
    self.content = content()
  }

  private var resolvedTitle: String {
    [title ?? "", "erikb.dev"].filter { !$0.isEmpty }
      .joined(separator: " | ")
  }

  private var copyrightYear: String {
    String(Calendar(identifier: .gregorian).component(.year, from: Date()))
  }

  let body = HTMLString()

  func render(into renderer: inout HTMLRenderer) {
    let main: HTMLString =
      /* html */
      """
      <header class="site-header">
        \({
          #if DEBUG
            /* html */
            """
            <div class="dev-banner" hx-get="\(router.path(for: .api(.liveReload(build: buildTimestamp))))" hx-trigger="every 2s" hx-swap="none" hx-on:htmx:error="this.classList.add('dev-banner--offline')" hx-on:htmx:response:error="this.classList.add('dev-banner--offline')" hx-on:htmx:after:request="this.classList.remove('dev-banner--offline')">
              <code><span class="dev-banner__ok">● CONNECTED</span><span class="dev-banner__offline">● DISCONNECTED</span></code>
            </div>
            """
          #endif
        })
        \(NavBlockSection(extraClass: "site-nav") {
          /* html */
          """
          <a href="/" class="brand-link"><code class="brand-text">erikb@dev:~<span class="prompt-symbol">$</span></code></a>
          """
        })
      </header>
      \(content)
      \(Divider())
      <footer>
        \(BlockSection(extraClass: "site-footer-copyright") { "© \(copyrightYear) erikb.dev" })
      </footer>
      """
    var page = HTMLRenderer()
    main.render(into: &page)

    let layout: HTMLString =
      /* html */
      """
      <!DOCTYPE html>
      <html data-theme="dark">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
        <title>\(resolvedTitle)</title>
        <link rel="icon" href="/favicon-16x16.png" type="image/png" sizes="16x16">
        <link rel="icon" href="/favicon-32x32.png" type="image/png" sizes="32x32">
        <link rel="icon" href="/favicon-96x96.png" type="image/png" sizes="96x96">
        <link rel="icon" href="/favicon-128x128.png" type="image/png" sizes="128x128">
        <style>
          :root {
            --font-sans: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", "Noto Sans", Arial, sans-serif;
            --font-mono: "CommitMono", ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;

            --color-base: #0a0a0a;
            --color-gridline: #1e1e1e;
            --size-gridline: 0.8px;
            --color-primary: #ffc900;
            --color-terminal: var(--color-primary);
            --color-danger: #ff5f56;
            --color-white: #fff;
            --color-body-text: #e0e0e0;
            --color-neutral-50: #f7f7f7;
            --color-neutral-300: #d4d4d4;
            --color-neutral-600: #6e6e6e;
            --color-neutral-700: #565656;
            --color-neutral-800: #3d3d3d;

            --header-height: 52px;
            --content-max-width: 56rem;
            --section-padding: 2rem;
          }

          /* Reset */

          *,
          *::before,
          *::after {
            box-sizing: border-box;
            border: 0 solid var(--color-gridline);
            margin: 0;
            padding: 0;
          }

          html {
            font-size: 12px;
            line-height: 1.5;
            -webkit-text-size-adjust: 100%;
          }

          body {
            height: 100%;
            background-color: var(--color-base);
            color: var(--color-body-text);
            font-family: var(--font-sans);
            font-optical-sizing: auto;
            overscroll-behavior: none;
          }

          h1, h2, h3, h4, h5, h6 {
            font-size: inherit;
            font-weight: inherit;
          }

          a {
            color: inherit;
            text-decoration: inherit;
          }

          code, kbd, samp, pre {
            font-family: var(--font-mono);
            line-height: 1;
          }

          img, svg, video {
            max-width: 100%;
            display: block;
          }

          ::selection {
            color: var(--color-base);
            background-color: var(--color-primary);
            text-decoration-color: var(--color-primary);
          }

          @font-face {
            font-family: "CommitMono";
            font-style: normal;
            font-weight: 400 600;
            font-display: swap;
            line-height: 16px;
            src: url("/fonts/CommitMono.woff2") format("woff2");
          }

          /* Layout: page shell */

          .site-body {
            overflow-x: hidden;
          }

          .site-header {
            position: sticky;
            top: 0;
            left: 0;
            z-index: 50;
            display: flex;
            flex-direction: column;
            width: 100%;
            background-color: rgba(10, 10, 10, 0.8);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            border-bottom: var(--size-gridline) solid var(--color-gridline);
          }

          .dev-banner {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            width: 100%;
            padding-block: 0.5rem;
            font-size: 0.75rem;
            font-family: var(--font-mono);
            background-color: var(--color-primary);
            color: var(--color-base);
            border-bottom: var(--size-gridline) solid var(--color-gridline);
          }

          .dev-banner--offline {
            background-color: var(--color-danger);
            color: var(--color-white);
          }

          .dev-banner__offline {
            display: none;
          }

          .dev-banner--offline .dev-banner__ok {
            display: none;
          }

          .dev-banner--offline .dev-banner__offline {
            display: inline;
          }

          .site-nav {
            position: sticky;
            background-color: transparent !important;
            height: var(--header-height);
            display: flex;
            flex: none;
            justify-content: space-between;
            align-items: center;
            padding-block: 0.75rem !important;
            padding-inline: 2rem !important;
          }

          .brand-link {
            align-self: center;
          }

          .brand-text {
            color: var(--color-white);
            font-weight: 700;
          }

          .prompt-symbol {
            color: var(--color-terminal);
          }

          .site-footer-copyright {
            padding-inline: 2rem !important;
            padding-block: 0 !important;
            height: var(--header-height);
            color: var(--color-neutral-600);
            display: flex;
            align-items: center;
            font-size: 0.875rem;
          }

          /* Home page */

          .whoami-prompt {
            display: inline-block;
            font-size: 0.875rem;
            text-align: start;
            color: var(--color-neutral-50);
            margin-bottom: 1.25rem;
          }

          .page-title {
            font-size: 1.875rem;
            font-weight: 700;
          }

          .role-line {
            color: var(--color-white);
          }

          .intro-text {
            margin-block: 1rem;
          }

          .link-row {
            display: flex;
            flex-direction: row;
            flex-wrap: wrap;
            gap: 0.5rem;
          }

          .pill-link {
            display: inline-block;
            border: var(--size-gridline) solid var(--color-gridline);
            padding: 0.5rem 0.75rem;
            transition: color 0.15s cubic-bezier(0.4, 0, 0.2, 1), border-color 0.15s cubic-bezier(0.4, 0, 0.2, 1);
          }

          @media (hover: hover) {
            .pill-link:hover {
              color: var(--color-white);
              border-color: var(--color-neutral-600);
            }
          }
        </style>
        \(unsafe: page.globalStyles.values.joined(separator: "\n"))
        <script src="/scripts/vendors/htmx.min.js"></script>
      </head>
      <body class="site-body">
        \(unsafe: page.output)
        \(unsafe: page.globalScripts.values.joined(separator: "\n"))
      </body>
      </html>
      """

    layout.render(into: &renderer)
  }
}
