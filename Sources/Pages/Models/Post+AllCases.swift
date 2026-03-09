// import Foundation
// import PublicAssets

extension Post: CaseIterable {
  static var allCases: [Self] {
    // @Dependency(\.publicAssets) var assetsDir

    return [
      Self(
        // header: .video(assetsDir.assets.posts.wledAppDemo.videoWebm),
        title: "A WLED Client for iOS",
        content: """
          I built a native iOS app for [WLED](https://github.com/wled/WLED), an open-source LED controller for ESP32, to control my RGB LED strips.
          """,
        date: Date(month: 8, day: 4, year: 2022),
        kind: .project,
        links: []
      ),
      Self(
        // header: .link("https://github.com/PrismMSI/PrismUI"),
        title: "PrismUI \u{2014} Controlling MSI RGB Keyboard on macOS",
        content: """
          When I set up my Hackintosh, I couldn't control the RGB keyboard on my MSI laptop since the software was supported on Windows only. To fix this issue, my first approach was to build an app using AppKit, C++, and Objective-C to communicate with the HID keyboard, which was ultimately called [SSKeyboardHue](https://github.com/erikbdev/SSKeyboardHue).

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
        // header: .image(
        //   assetsDir.assets.posts.animeNowReleased.anDiscoverWebp,
        //   label: "Anime Now! discover image"
        // ),
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
          I've also built a library called [swift-web](https://github.com/erikbdev/swift-web) which contains tools used to build \
          this website.

          Feel free to check out both projects on GitHub. 😊
          """,
        date: Date(month: 2, day: 2, year: 2025),
        // lastUpdated: Date(month: 3, day: 15, year: 2025),
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
        title: "XTool is Awesome",
        content: """
          [xtool](https://github.com/xtool-org/xtool) is a tool that attempts to replace Xcode and use Swift Package Manager to \
          build and deploy iOS apps on macOS, Linux, and Windows! \
          I have been working closely with the developer to support for App Extensions and also resolve additional issues.

          I hope to also replace "AppleProductTypes", a library used to build iOS and macOS apps using Swift Playgrounds, in favor of \
          "XToolProductTypes."
          """,
        date: Date(month: 7, day: 20, year: 2025),
        kind: .blog,
        hidden: true
      ),
    ]
    .sorted { $0.date < $1.date }
    .filter { !$0.hidden }
  }
}
