import Elementary
import Foundation
import Shared

struct HomePage: HTML {
  var activity: Activity?

  private static let postDateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "MMM d, yyyy"
    f.timeZone = TimeZone(identifier: "UTC")
    return f
  }()

  var body: some HTML {
    Layout {
      BlockSection(id: "user") {
        header {
          a(.href("#user"), .class("whoami-prompt")) {
            span(.class("prompt-symbol")) { "$" }
            " whoami"
          }

          h1(.class("page-title")) { "Erik Bautista Santibanez" }

          p(.class("role-line")) { "Mobile & Web Developer" }
          p { (activity?.location?.residency ?? .default).description }

          div(.id("activity"), .hx.get("/api/activity"), .hx.trigger(.event(.load))) {
            ActivityFragment(activity: activity)
          }

          p(.class("intro-text")) {
            "I'm a passionate software developer who builds applications using Swift and modern web technologies."
          }

          div(.class("link-row")) {
            a(.href("mailto:me@erikb.dev"), .class(linkClass)) { "/me@erikb.dev" }
            a(.href("/resume.pdf"), .custom(name: "target", value: "_blank"), .class(linkClass)) { "/resume.pdf" }
            a(.href("https://github.com/erikbdev"), .custom(name: "target", value: "_blank"), .class(linkClass)) { "/github" }
            a(.href("https://linkedin.com/in/erikbautista"), .custom(name: "target", value: "_blank"), .class(linkClass)) { "/linkedin" }
          }
        }
      }

      BlockSection(flush: true) {
        header(.class("dev-logs-header")) {
          a(.href("#dev-logs"), .class("devlogs-prompt")) {
            span(.class("prompt-symbol")) { "$" }
            " ls -l /dev-logs/"
          }
          h1(.class("devlogs-title")) { "Dev Logs" }
          p(.class("devlogs-subtitle")) { "A curated list of projects I've worked on." }
        }

        ForEach(Post.published) { post in
          article(.id(post.id), .class("log-entry")) {
            header {
              hgroup(.class("log-entry-meta")) {
                a(.href("#\(post.id)")) {
                  span(.class("prompt-symbol")) { "$" }
                  " cat log-\(post.index).md"
                }
                span(.class("log-entry-date")) { Self.postDateFormatter.string(from: post.date) }
              }
            }

            section(.class("log-entry-body")) {
              MarkdownHTML(markdown: post.markdownBody)
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
    }
  }

  private var linkClass: String { "pill-link" }
}
