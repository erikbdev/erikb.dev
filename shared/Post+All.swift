import Foundation

extension Post: CaseIterable {
  public static let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "MM-dd-yyyy"
    f.timeZone = TimeZone(identifier: "UTC")
    return f
  }()

  private static func date(_ string: String) -> Date {
    Self.dateFormatter.date(from: string) ?? .now
  }

  public static let published: [Post] = {
    var ascending = Post.allCases
      .filter { !$0.hidden }
      .sorted { $0.date < $1.date }

    for i in ascending.indices {
      ascending[i].id = "logs-\(i)"
      ascending[i].index = i
    }

    return ascending.reversed()
  }()

  public static let allCases: [Post] = [
    Post(
      title: "PrismUI — Controlling MSI RGB Keyboard on macOS",
      date: date("08-08-2021"),
      kind: .project,
      links: [
        Link(label: "PrismUI on GitHub", href: "https://github.com/erikbdev/PrismUI", role: .primary),
        Link(label: "SSKeyboardHue on GitHub", href: "https://github.com/erikbdev/SSKeyboardHue", role: .secondary),
      ],
      markdownBody: """
        # PrismUI — Controlling MSI RGB Keyboard on macOS

        When I configured my Hackintosh, I was unable to control the RGB keyboard on my MSI laptop due to the software only being supported on Windows. To resolve this issue, my first approach was to build an app using AppKit, C++, and Objective-C to communicate with the HID keyboard, which was ultimately called [SSKeyboardHue](https://github.com/erikbdev/SSKeyboardHue).

        Later, I decided to switch the communication protocol to Swift and redesign the front end using SwiftUI.

        Both projects are available on GitHub — feel free to check them out!
        """
    ),
    Post(
      title: "A WLED Client for iOS",
      date: date("08-04-2022"),
      kind: .project,
      header: .video(src: "/posts/wled-app-demo/video.webm", label: "WLED App Demo"),
      markdownBody: """
        # A WLED Client for iOS

        I built a native iOS app for [WLED](https://github.com/wled/WLED), an open-source LED controller for ESP32, to control my RGB LED strips.
        """
    ),
    Post(
      title: "Anime Now! — An iOS and macOS App",
      date: date("09-15-2022"),
      kind: .project,
      header: .image(src: "/posts/anime-now-released/an-discover.webp", label: "Anime Now! discover image"),
      markdownBody: """
        # Anime Now! — An iOS and macOS App
        """
    ),
    Post(
      title: "Mochi — Content Viewer for iOS and macOS",
      date: date("12-10-2023"),
      kind: .project,
      links: [
        Link(label: "Mochi Website", href: "https://mochi.erikb.dev", role: .primary)
      ],
      hidden: true,
      markdownBody: """
        # Mochi — Content Viewer for iOS and macOS
        """
    ),
    Post(
      title: "Website Redesign",
      date: date("02-02-2025"),
      kind: .blog,
      header: .code(
        lang: "swift",
        value: """
          struct Portfolio: HTML {
            var body: some HTML {
              HomePage()
            }
          }
          """
      ),
      links: [
        Link(label: "Portfolio on GitHub", href: "https://github.com/erikbdev/erikbautista.dev", role: .primary),
        Link(label: "swift-web on GitHub", href: "https://github.com/erikbdev/swift-web", role: .secondary),
      ],
      markdownBody: """
        ```swift
        struct Portfolio: HTML {
          var body: some HTML {
            HomePage()
          }
        }
        ```

        # Website Redesign

        I redesigned my website, but instead of using traditional web frameworks, I used Swift! I've also built a library called [swift-web](https://github.com/erikbdev/swift-web) which contains tools used to build this website.

        Feel free to check out both projects on GitHub. 😊
        """
    ),
    Post(
      title: "xtool is Awesome!",
      date: date("07-20-2025"),
      kind: .blog,
      links: [
        Link(label: "xtool on GitHub", href: "https://github.com/xtool-org/xtool", role: .primary)
      ],
      markdownBody: """
        # xtool is Awesome!

        [xtool](https://github.com/xtool-org/xtool) is a tool that attempts to replace Xcode by using Swift Package Manager to build and deploy iOS apps on macOS, Linux, and Windows! I have been working closely with the developer to support for App Extensions and also resolve additional issues.

        I hope to also replace "AppleProductTypes", a library used to build iOS and macOS apps using Swift Playgrounds, in favor of "XToolProductTypes."
        """
    ),
    Post(
      title: "An Interactive Portfolio Over SSH",
      date: date("07-01-2026"),
      kind: .blog,
      links: [
        Link(label: "erikb.dev on GitHub", href: "https://github.com/erikbdev/erikb.dev", role: .primary),
        Link(label: "swift-nio-ssh on GitHub", href: "https://github.com/apple/swift-nio-ssh", role: .secondary),
      ],
      markdownBody: """
        # An Interactive Portfolio Over SSH

        I've been working with [swift-nio-ssh](https://github.com/apple/swift-nio-ssh) to build an interactive, terminal-based version of this portfolio that you can access straight from your terminal. It renders a full TUI experience over an SSH connection using Swift.

        Give it a try:

        ```bash
        $ ssh erikb.dev
        ```
        """
    ),
  ]
}

extension Post {
  public var formattedDate: String {
    Self.dateFormatter.string(from: self.date)
  }
}
