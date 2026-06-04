import Foundation

struct Post: Identifiable, Sendable {
  let id: String
  let index: Int
  let title: String
  let body: String
  let date: Date
  let kind: Kind
  let links: [Link]

  enum Kind: String, Sendable {
    case project, blog
  }

  struct Link: Sendable {
    let label: String
    let href: String
  }

  var formattedDate: String {
    Post.displayFormatter.string(from: date)
  }
}

extension Post {
  private static let displayFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .medium
    f.timeStyle = .none
    return f
  }()

  // Newest first — mirrors the web portfolio order.
  static let all: [Post] = {
    let f = DateFormatter()
    f.dateFormat = "MM-dd-yyyy"
    func date(_ s: String) -> Date { f.date(from: s)! }

    return [
      Post(
        id: "logs-4",
        index: 4,
        title: "xtool is Awesome!",
        body: """
          xtool is a cross-platform tool that attempts to replace Xcode by \
          using Swift Package Manager to build and deploy iOS apps on macOS, \
          Linux, and Windows. I have been working closely with the developer \
          to add support for App Extensions and resolve additional issues. \
          I also hope to replace AppleProductTypes in favor of XToolProductTypes.
          """,
        date: date("07-20-2025"),
        kind: .blog,
        links: [
          Link(label: "xtool on GitHub", href: "https://github.com/xtool-org/xtool")
        ]
      ),
      Post(
        id: "logs-3",
        index: 3,
        title: "Website Redesign",
        body: """
          Redesigned my portfolio website using Swift instead of traditional \
          web frameworks. I built swift-web, a library for server-side Swift \
          HTML generation with a SwiftUI-inspired API, and used it as the \
          foundation for this site.
          """,
        date: date("02-02-2025"),
        kind: .blog,
        links: [
          Link(label: "Portfolio on GitHub", href: "https://github.com/erikbdev/erikbautista.dev"),
          Link(label: "swift-web on GitHub", href: "https://github.com/erikbdev/swift-web"),
        ]
      ),
      Post(
        id: "logs-2",
        index: 2,
        title: "Anime Now! — An iOS and macOS App",
        body: """
          Built a native iOS and macOS app for discovering and watching anime. \
          Features include library tracking, episode progress management, and \
          a clean SwiftUI interface.
          """,
        date: date("09-15-2022"),
        kind: .project,
        links: []
      ),
      Post(
        id: "logs-1",
        index: 1,
        title: "A WLED Client for iOS",
        body: """
          Built a native iOS app to control WLED — an open-source firmware for \
          ESP32-based LED controllers — for managing RGB LED strips over WiFi \
          with full color, brightness, and effect control.
          """,
        date: date("08-04-2022"),
        kind: .project,
        links: []
      ),
      Post(
        id: "logs-0",
        index: 0,
        title: "PrismUI — Controlling MSI RGB Keyboard on macOS",
        body: """
          Reverse-engineered the USB HID protocol used by MSI RGB keyboards \
          to enable macOS control, which was otherwise unavailable through \
          official software. First built SSKeyboardHue using AppKit and \
          Objective-C, then rebuilt it as PrismUI in Swift and SwiftUI.
          """,
        date: date("08-08-2021"),
        kind: .project,
        links: [
          Link(label: "PrismUI on GitHub", href: "https://github.com/erikbdev/PrismUI"),
          Link(label: "SSKeyboardHue on GitHub", href: "https://github.com/erikbdev/SSKeyboardHue"),
        ]
      ),
    ]
  }()
}
