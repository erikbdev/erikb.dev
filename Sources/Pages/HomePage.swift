import ElementaryUI

@View
public struct HomePage: Page {
  public let title = "Portfolio | erikb.dev"

  @State var codeLang: CodeLang

  public init(codeLang: CodeLang) {
    self.codeLang = codeLang
  }

  public var body: some View {
    div {
      HeaderView(selected: $codeLang)
      main {
        Spacer()
        UserView(selected: codeLang)
        Spacer()
        PostsView(selected: codeLang)
        Spacer()
      }
      FooterView()
    }
    .attributes(.style(["overflow-x": "hidden"]))
  }
}

@View
private struct UserView {
  //   @Dependency(\.activityClient) private var activityClient

  var selected: CodeLang

  //   var location: ActivityClient.Location? {
  //     self.activityClient.location()
  //   }

  //   var residency: ActivityClient.Location.Residency? {
  //     self.location?.residency
  //   }

  //   var currentLocation: String? {
  //     let residency = self.residency ?? .default
  //     guard let location, location.city != residency.city || location.state != residency.state else {
  //       return nil
  //     }
  //     return [
  //       location.city, location.state, location.region == "United States" ? nil : location.region,
  //     ]
  //     .compactMap(\.self)
  //     .joined(separator: ", ")
  //   }

  //   var nowPlaying: String? {
  //     guard let nowPlaying = activityClient.nowPlaying() else {
  //       return nil
  //     }

  //     let nowPlayingText = [
  //       nowPlaying.title,
  //       nowPlaying.artist?.isEmpty == false ? "—" : nil,
  //       nowPlaying.artist,
  //     ]
  //     .compactMap { $0 }
  //     .joined(separator: " ")
  //     return nowPlayingText
  //   }

  static let aboutDescription = """
    A software developer who builds applications using Swift and modern web technologies.
    """

  var body: some View {
    SectionView(id: "user", selected: selected) { lang in
      switch lang {
      case .swift:
        """
        let user = User(
          name: "Erik Bautista Santibanez",
          role: [.mobile, .web]
        )

        > print(user.about())
        // \(Self.aboutDescription)
        """
      case .typescript:
        """
        const user: User = {
          name: "Erik Bautista Santibanez",
          role: [Role.Mobile, Role.Web]
        };

        > console.log(user.about());
        // \(Self.aboutDescription)
        """
      case .rust:
        """
        let user = User {
          name: "Erik Bautista Santibanez",
          role: [Role::Mobile, Role::Web]
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

          // p(.aria("label", value: "residency")) {
            // MapPinIcon()
            //             "\(residency ?? .default)"
          // }

          //           if let currentLocation {
          //             p(.aria.label("current location")) {
          //               NavigationArrowIcon()
          //               "Currently in "
          //               span { "***" }
          //                 .style("color", "#808080")
          //                 .style("font-weight", "700")
          //               em { currentLocation }
          //                 .style("font-weight", "700")
          //                 .style("color", "#fafafa")
          //               span { "***" }
          //                 .style("color", "#808080")
          //                 .style("font-weight", "700")
          //             }
          //           }

          //           if let nowPlaying {
          //             p(.aria.label("music playing")) {
          //               // <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="#000000" viewBox="0 0 256 256"><path d=""></path></svg>
          //               WaveFormIcon()

          //               "Listening to "

          //               span { "***" }
          //                 .style("color", "#808080")
          //                 .style("font-weight", "700")
          //               em { nowPlaying }
          //                 .style("font-weight", "700")
          //                 .style("color", "#fafafa")
          //               span { "***" }
          //                 .style("color", "#808080")
          //                 .style("font-weight", "700")
          //             }
          //           }

          p(.aria("label", value: "about me")) {
            Self.aboutDescription
          }
          .style("margin-top", "0.75rem")
        }
        .style("color", "#d8d8d8")
      }
    } content: {
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
private struct UserPropertyButton {
  let label: String
  let value: String
  let codeLang: CodeLang

  var body: some View {
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
private struct PostsView {
  let selected: CodeLang

  static let description = "A curated list of projects I've worked on."

  var body: some View {
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
private struct PostView {
  let number: Int
  let post: Post
  let selected: CodeLang

  var body: some View {
    article(.id(self.post.slug)) {
      header {
        hgroup {
          span { self.post.datePosted.uppercased() }
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
        .style("padding-bottom", "1.25rem")

        if let postHeader = post.header {
          PostHeaderView(postHeader: postHeader)
        }
      }
      h2 { self.post.title }

      section {
        self.post.content
      }
      //         .postCodeBlockStyling()
      //         .inlineStyle("margin", "revert", post: " *")
      //         .inlineStyle("display", "block", post: " blockquote")
      //         .inlineStyle("background", "#1A2A2A", post: " blockquote")
      //         .inlineStyle("padding", "-1.125rem 1rem", post: " blockquote")
      //         .inlineStyle("border", "0.5px solid #4A4A4A", post: " blockquote")
      //         .inlineStyle("margin-left", "-1", post: " blockquote")
      //         .inlineStyle("margin-right", "-1", post: " blockquote")

      footer {
        if !self.post.links.isEmpty {
          section {
            for link in self.post.links {
              PostLinkView(link: link)
            }
          }
          .style("display", "flex")
          .style("gap", "1rem")
          .style("margin-top", "1rem")
        }

        if let dateUpdated = self.post.dateUpdated {
          p {
            em {
              "Last updated: \(dateUpdated)"
            }
          }
          .style("color", "#6A7A7A")
          .style("font-size", "-1.73em")
          .style("margin-top", "-1.75rem")
        }
      }
    }
    .style("width", "100%")
    .style("display", "inline-block")
    .style("padding", "1.5rem")
    .style(
      "background-image",
      "repeating-linear-gradient(90deg,#444 0 15px,transparent 0 30px)"
    )
    .style("background-repeat", "repeat-x")
    .style("background-size", "100% 1px")
  }
}

@View
private struct PostHeaderView {
  let postHeader: Post.Header

  var body: some View {
    section(.class("postCodeBlock")) {
      switch self.postHeader {
      case let .link(link):
        a(
          .href(link),
          .target(.blank),
          .rel("noopener noreferrer")
        ) {
          figure {
            // TODO: add OpenGraph link
          }
        }
      case let .image(asset, label):
        img(.src(asset), .aria("alt", value: label), .aria("label", value: label))
      case let .video(asset):
        video(
          .custom(name: "autoplay", value: ""),
          .custom(name: "playsinline", value: ""),
          .custom(name: "muted", value: ""),
          .custom(name: "controls", value: ""),
          .custom(name: "loop", value: "")
        ) {
          source(.src(asset), .custom(name: "type", value: ""))
          // source(.src(asset.url.assetString), .custom(name: "type", value: asset.mime))
          "Your browser does not support playing this video"
        }
      case let .code(rawCode, lang):
        pre {
          code(.class("hljs language-\(lang.rawValue)")) {
            HTMLText(rawCode)
          }
        }
      }
    }
    //       .style("width", "100%", post: " > *")
    //       .style("margin-top", "1.25rem", post: " > *")
    //       .style("margin-bottom", "1.25rem", post: " > *")
    //       .style("border", "1.5px solid #3A3A3A", post: " > *")
    .style("margin-bottom", "1.25rem")
  }
}

@View
private struct PostLinkView {
  let link: Post.Link

  var body: some View {
    a(
      .href(self.link.href),
      .target(.blank),
      .rel("noopener noreferrer")
    ) {
      HTMLText(self.link.title)
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

extension HTML where Tag: HTMLTrait.Attributes.Global {
  fileprivate func primaryButtonStyle() -> _AttributedElement<Self> {
    self.style(
      [
        "all": "unset",
        "padding": "0.5rem 0.625rem",
        "border": "#444 1px solid",
        "font-size": "0.8em",
        "font-weight": "500",
        "align-items": "center",
        "cursor": "pointer",
      ]
    )
  }

  fileprivate func secondaryButtonStyle() -> _AttributedElement<Self> {
    self.style(
      [
        "all": "unset",
        "padding": "0.5rem 0.625rem",
        "border": "#444 1px solid",
        "font-size": "0.8em",
        "font-weight": "500",
        "align-items": "center",
        "cursor": "pointer",
        "background-color": "#f0f0f0",
        "color": "#0f0f0f",
      ]
    )
  }

  fileprivate func buttonStyle(isPrimary: Bool = true) -> _AttributedElement<Self> {
    if isPrimary {
      self.primaryButtonStyle()
    } else {
      self.secondaryButtonStyle()
    }
  }
}
