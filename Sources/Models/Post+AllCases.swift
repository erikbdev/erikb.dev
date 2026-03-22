import Dependencies
import PublicAssets

extension Post: CaseIterable {
  public static let allCases = {
    @Dependency(\.publicAssets) var publicAssets
    return [
      Self(
        header: .video(publicAssets.assets.posts.wledAppDemo.videoWebm),
        title: "A WLED Client for iOS",
        content: """
          I built a native iOS app for \("WLED", url: "https://github.com/wled/WLED"), an open-source LED controller for ESP32, to control my RGB LED strips.
          """,
        date: Date(month: 8, day: 4, year: 2022),
        kind: .project,
        links: []
      ),
      Self(
        // header: .link("https://github.com/PrismMSI/PrismUI"),
        title: "PrismUI \u{2014} Controlling MSI RGB Keyboard on macOS",
        content: """
          When I configured my Hackintosh, I was unable to control the RGB keyboard on my MSI laptop due to the software only being supported on Windows. \
          To resolve this issue, my first approach was to build an app using AppKit, C++, and Objective-C to communicate with the HID keyboard, which was ultimately called \("SSKeyboardHue", url: "https://github.com/erikbdev/SSKeyboardHue"). 

          Later, I decided to switch the communication protocol to Swift and redesign the front end using SwiftUI.

          Both projects are available on GitHub — feel free to check them out!
          """,
        date: Date(month: 8, day: 8, year: 2021),
        kind: .project,
        links: [
          .init(
            title: "PrismUI on GitHub",
            href: "https://github.com/erikbdev/PrismUI",
            role: .primary
          ),
          .init(
            title: "SSKeyboardHue on GitHub",
            href: "https://github.com/erikbdev/SSKeyboardHue",
            role: .secondary
          ),
        ]
      ),
      Self(
        header: .image(
          publicAssets.assets.posts.animeNowReleased.anDiscoverWebp,
          label: "Anime Now! discover image"
        ),
        title: "Anime Now! \u{2014} An iOS and macOS App",
        content: """
          """,
        date: Date(month: 9, day: 15, year: 2022),
        kind: .project
      ),
      Self(
        title: "Mochi \u{2014} Content Viewer for iOS and macOS",
        content: """
          """,
        date: Date(month: 12, day: 10, year: 2023),
        kind: .project,
        links: [
          .init(
            title: "Mochi Website",
            href: "https://mochi.erikb.dev",
            role: .primary
          )
        ]
      ),
      Self(
        header: .code(
          """
          struct Portfolio: HTML {
            var body: some HTML {
              HomePage()
            }
          }
          """,
          lang: .swift
        ),
        title: "Website Redesign",
        content: """
          I redesigned my website, but instead of using traditional web frameworks, I used Swift! \
          I've also built a library called \("swift-web", url: "https://github.com/erikbdev/swift-web") which contains tools used to build \
          this website.

          Feel free to check out both projects on GitHub. 😊
          """,
        date: Date(month: 2, day: 2, year: 2025),
        kind: .blog,
        links: [
          Post.Link(
            title: "Portfolio on GitHub",
            href: "https://github.com/erikbdev/erikbautista.dev",
            role: .primary
          ),
          Post.Link(
            title: "swift-web on GitHub",
            href: "https://github.com/erikbdev/swift-web",
            role: .secondary
          ),
        ]
      ),
      Self(
        title: "xtool is Awesome!",
        content: """
          \("xtool", url: "https://github.com/xtool-org/xtool") is a tool that attempts to replace Xcode by using Swift Package Manager to \
          build and deploy iOS apps on macOS, Linux, and Windows! \
          I have been working closely with the developer to support for App Extensions and also resolve additional issues.

          I hope to also replace "AppleProductTypes", a library used to build iOS and macOS apps using Swift Playgrounds, in favor of \
          "XToolProductTypes."
          """,
        date: Date(month: 7, day: 20, year: 2025),
        kind: .blog,
        links: [
          Post.Link(
            title: "xtool on GitHub",
            href: "https://github.com/xtool-org/xtool",
            role: .primary
          )
        ]
      ),
    ]
    .sorted { $0.date < $1.date }
    .filter { !$0.hidden }
  }()
}
