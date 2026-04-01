import ElementaryUI
import Models

@View
public struct HomePage: Page {
  public let title = "Portfolio | erikb.dev"

  @State var codeLang: CodeLang
  @State var activity: Activity?

  public init(codeLang: CodeLang, activity: Activity?) {
    self.codeLang = codeLang
    self.activity = activity
  }

  public var body: some View {
    div {
      HeaderView(selected: $codeLang)
      main {
        Spacer()
        UserView(selected: codeLang, activity: activity)
        Spacer()
        PostsView(selected: codeLang)
        Spacer()
      }
      FooterView()
    }
    .style("overflow-x", "hidden")
  }
}

@View
public struct UserView {
  let selected: CodeLang
  let activity: Activity?

  var location: Activity.Location? { self.activity?.location }

  var residency: Activity.Location.Residency? {
    self.location?.residency
  }

  var currentLocation: String? {
    let residency = self.residency ?? .default
    guard let location, location.city != residency.city || location.state != residency.state else {
      return nil
    }
    return [
      location.city, location.state, location.region == "United States" ? nil : location.region,
    ]
    .compactMap { $0 }
    .joined(separator: ", ")
  }

  var nowPlaying: String? {
    guard let nowPlaying = activity?.nowPlaying else {
      return nil
    }

    let nowPlayingText = [
      nowPlaying.title,
      nowPlaying.artist?.isEmpty == false ? "—" : nil,
      nowPlaying.artist,
    ]
    .compactMap { $0 }
    .joined(separator: " ")
    return nowPlayingText
  }

  static let aboutDescription = """
    A software developer who builds applications using Swift and modern web technologies.
    """

  public var body: some View {
    SectionView(
      id: "user",
      selected: selected
    ) { [residency, currentLocation, nowPlaying] lang in
      switch lang {
      case .swift:
        """
        let user = User(
          name: "Erik Bautista Santibanez",
          role: [.mobile, .web],
          home: "\(residency ?? .default)"\
        \(currentLocation.flatMap { ",\n  location: \"Currently in \($0)\"" } ?? "")\
        \(nowPlaying.flatMap { ",\n  listeningTo: \"\($0)\"" } ?? "")
        )

        > print(user.about())
        // \(Self.aboutDescription)
        """
      case .typescript:
        """
        const user: User = {
          name: "Erik Bautista Santibanez",
          role: [Role.Mobile, Role.Web],
          home: "\(residency ?? .default)"\
        \(currentLocation.flatMap { ",\n  location: \"Currently in \($0)\"" } ?? "")\
        \(nowPlaying.flatMap { ",\n  listeningTo: \"\($0)\"" } ?? "")
        };

        > console.log(user.about());
        // \(Self.aboutDescription)
        """
      case .rust:
        """
        let user = User {
          name: "Erik Bautista Santibanez",
          role: [Role::Mobile, Role::Web],
          home: "\(residency ?? .default)"\
        \(currentLocation.flatMap { ",\n  location: \"Currently in \($0)\"" } ?? "")\
        \(nowPlaying.flatMap { ",\n  listeningTo: \"\($0)\"" } ?? "")
        };

        > println!("{}", user.about());
        // \(Self.aboutDescription)
        """
      case .markdown:
        h1(.aria("label", value: "name")) {
          span { "#" }
            .attributes(.style(["color": "#808080", "font-weight": "700"]))
          " "
          "Erik Bautista Santibanez"
        }
        .style("margin-bottom", "0.25rem")

        div {
          p(.aria("label", value: "occupation")) { "Mobile & Web Developer" }
          p(.aria("label", value: "residency")) {
            MapPinIcon()
            "\(residency ?? .default)"
          }

          if let currentLocation {
            p(.aria("label", value: "current location")) {
              NavigationArrowIcon()
              "Currently in "
              span { "***" }
                .style("color", "#808080")
                .style("font-weight", "700")
              em { currentLocation }
                .style("font-weight", "700")
                .style("color", "#fafafa")
              span { "***" }
                .style("color", "#808080")
                .style("font-weight", "700")
            }
          }

          if let nowPlaying {
            p(.aria("label", value: "music playing")) {
              WaveFormIcon()

              "Listening to "

              span { "***" }
                .style("color", "#808080")
                .style("font-weight", "700")
              em { nowPlaying }
                .style("font-weight", "700")
                .style("color", "#fafafa")
              span { "***" }
                .style("color", "#808080")
                .style("font-weight", "700")
            }
          }

          p(.aria("label", value: "about me")) {
            Self.aboutDescription
          }
          .style("margin-top", "0.75rem")
        }
        .style("color", "#d8d8d8")
      }
    } content: { [selected] in
      div {
        div {
          a(.href("mailto:me@erikb.dev")) {
            UserPropertyButton(
              label: "email",
              value: "me@erikb.dev",
              codeLang: selected
            )
          }
          .primaryButtonStyle()

          a(
            .href("https://github.com/erikbdev"),
            .target(.blank),
            .rel("noopener noreferrer")
          ) {
            UserPropertyButton(
              label: "github",
              value: "/erikbdev",
              codeLang: selected
            )
          }
          .secondaryButtonStyle()

          a(
            .href("https://www.linkedin.com/in/erikbautista"),
            .target(.blank),
            .rel("noopener noreferrer")
          ) {
            UserPropertyButton(
              label: "linkedin",
              value: "/erikbautista",
              codeLang: selected
            )
          }
          .secondaryButtonStyle()
        }
        .style("display", "flex")
        .style("flex-direction", "row")
        .style("flex-wrap", "wrap")
        .style("gap", "0.625rem")
      }
      .style("margin-top", "-1rem")
      .style("padding", "0 1.5rem 1.5rem")
    }
  }
}

@View
public struct UserPropertyButton {
  let label: String
  let value: String
  let codeLang: CodeLang

  public var body: some View {
    code {
      if codeLang == .markdown {
        "[\(label)](\(value))"
      } else {
        "user.\(label)()\(codeLang.hasSemiColon ? ";" : "")"
      }
    }
  }
}

@View
public struct PostsView: Sendable {
  let selected: CodeLang

  static let description = "A curated list of projects I've worked on."

  public var body: some View {
    SectionView(id: "dev-logs", selected: selected) { lang in
      switch lang {
      case .swift:
        """
        // \(Self.description)
        let logs: [DevLog] = await fetch(.all)
        """
      case .typescript:
        """
        // \(Self.description)
        const logs = await fetch(Filter.All);
        """
      case .rust:
        """
        // \(Self.description)
        let logs = fetch(Filter::All).await;
        """
      case .markdown:
        h1 {
          span { "#" }
            .style("color", "#808080")
            .style("font-weight", "700")
          " "
          "Dev Logs"
        }
        .style("margin-bottom", "0.25rem")

        p { Self.description }
          .style("color", "#d8d8d8")
      }
    } content: {
      for (num, post) in Post.allCases.enumerated().reversed() {
        PostView(number: num, post: post, selected: selected)
      }
    }
  }
}

@View
public struct PostView {
  let number: Int
  let post: Post
  let selected: CodeLang

  public var body: some View {
    article(.id(self.post.slug)) {
      header {
        hgroup {
          span { self.post.datePosted }
            .style("flex-grow", "1")
            .style("color", "#9A9A9A")
            .style("font-size", "0.75em")
            .style("font-weight", "599")

          pre {
            a(.href("#\(self.post.slug)")) {
              code(.class("hljs \("language-\(selected.rawValue)")")) {
                switch selected {
                case .markdown: "log-\(self.number).md"
                default: "logs[\(self.number)]"
                }
              }
            }
            .style("color", "#777")
          }
          .style("font-size", "0.75em")
          .style("font-weight", "500")
          .style("text-align", "end")
        }
        .style("display", "flex")
        .style("align-items", "baseline")
        .style("margin-bottom", "1rem")

        if let postHeader = post.header {
          PostHeaderView(postHeader: postHeader)
        }
      }

      h3 { PostTextContentView(textContent: self.post.title) }
        .style(
          "margin-bottom",
          !self.post.content.rawValue.isEmpty ? "0.5rem" : !self.post.links.isEmpty || self.post.lastUpdated != nil ? "1rem" : "0rem"
        )

      if !self.post.content.rawValue.isEmpty {
        p { PostTextContentView(textContent: self.post.content) }
          .style("white-space", "pre-wrap")
          .style("margin-bottom", self.post.links.isEmpty && self.post.lastUpdated == nil ? "0rem" : "1rem")
      }

      if !self.post.links.isEmpty || self.post.lastUpdated != nil {
        footer {
          if !self.post.links.isEmpty {
            section {
              for link in self.post.links {
                PostLinkView(link: link)
              }
            }
            .style("display", "flex")
            .style("gap", "0.75rem")
            .style("flex-wrap", "wrap")
          }

          if let dateUpdated = self.post.dateUpdated {
            p { em { "Last updated: \(dateUpdated)" } }
              .style("color", "#6A7A7A")
              .style("font-size", "-1.73em")
          }
        }
      }
    }
    .style("width", "100%")
    .style("display", "inline-block")
    .style("padding", "1.5rem")
    .style("background-image", "repeating-linear-gradient(90deg,#444 0 15px,transparent 0 30px)")
    .style("background-repeat", "repeat-x")
    .style("background-size", "100% 1px")
  }
}

@View
public struct PostHeaderView {
  let postHeader: Post.Header

  public var body: some View {
    section {
      switch self.postHeader {
      // case let .link(link):
      //   a(
      //     .href(link),
      //     .target(.blank),
      //     .rel("noopener noreferrer")
      //   ) {
      //     figure {
      //       // TODO: add OpenGraph link
      //     }
      //   }
      case let .image(asset, label):
        img(.src(asset.path), .aria("alt", value: label), .aria("label", value: label))
      case let .video(asset):
        video(
          .custom(name: "autoplay", value: ""),
          .custom(name: "playsinline", value: ""),
          .custom(name: "muted", value: ""),
          .custom(name: "controls", value: ""),
          .custom(name: "loop", value: "")
        ) {
          source(.src(asset.path), .custom(name: "type", value: asset.mime))
          "Your browser does not support playing this video"
        }
      case let .code(rawCode, lang):
        pre {
          code(.class("hljs language-\(lang.rawValue)")) {
            rawCode
          }
        }
        .style("padding", "0.75rem")
        .style("font-size", "0.85em")
      }
    }
    .style("background", "#242423")
    .style("border", "1.5px solid #3A3A3A")
    .style("overflow-x", "auto")
    .style("width", "100%")
    .style("margin-bottom", "1.25rem")
  }
}

@View
public struct PostTextContentView {
  let textContent: Post.TextContent

  public var body: some View {
    for element in textContent.content {
      switch element {
      case .text(let text): HTMLText("\(text)")
      case let .link(title, url):
        a(.target(.blank), .href("\(url)")) {
          HTMLText("\(title)")
        }
      }
    }
  }
}

@View
public struct PostLinkView {
  let link: Post.Link

  public var body: some View {
    a(
      .href(self.link.href),
      .target(.blank),
      .rel("noopener noreferrer")
    ) {
      self.link.title
      " "
      if self.link.isExternal {
        svg(
          .xmlns(),
          .fill("currentColor"),
          .viewBox("0 0 256 256"),
          .aria("label", value: "external link icon")
        ) {
          path(
            .d(
              "M228,104a12,12,0,0,1-24,0V69l-59.51,59.51a12,12,0,0,1-17-17L187,52H152a12,12,0,0,1,0-24h64a12,12,0,0,1,12,12Zm-44,24a12,12,0,0,0-12,12v64H52V84h64a12,12,0,0,0,0-24H48A20,20,0,0,0,28,80V208a20,20,0,0,0,20,20H176a20,20,0,0,0,20-20V140A12,12,0,0,0,184,128Z"
            )
          )
        }
        .svgIconStyling()
      } else {
        svg(
          .xmlns(),
          .fill("currentColor"),
          .viewBox("0 0 256 256"),
          .aria("label", value: "external link icon")
        ) {
          path(
            .d(
              "M224.49,136.49l-72,72a12,12,0,0,1-17-17L187,140H40a12,12,0,0,1,0-24H187L135.51,64.48a12,12,0,0,1,17-17l72,72A12,12,0,0,1,224.49,136.49Z"
            )
          )
        }
        .svgIconStyling()
      }
    }
    .buttonStyle(isPrimary: self.link.role == .primary)
  }
}

extension HTML where Self: _Attributed, Tag: HTMLTrait.Attributes.Global {
  fileprivate func primaryButtonStyle() -> Self {
    self.style(
      [
        "text-decoration": "none",
        "padding": "0.5rem 0.625rem",
        "border": "#444 1px solid",
        "font-size": "0.8em",
        "font-weight": "500",
        "align-items": "center",
        "cursor": "pointer",
      ]
    )
  }

  fileprivate func secondaryButtonStyle() -> Self {
    self.primaryButtonStyle()
      .style(
        [
          "background-color": "#f0f0f0",
          "color": "#0f0f0f",
        ]
      )
  }

  fileprivate func buttonStyle(isPrimary: Bool = true) -> Self {
    if isPrimary {
      self.primaryButtonStyle()
    } else {
      self.secondaryButtonStyle()
    }
  }
}
