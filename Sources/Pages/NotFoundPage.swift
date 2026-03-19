import ElementaryUI
import Shared

@View
public struct NotFoundPage: Page {
  private static let notFoundDescription = "The asset or page could not be found"

  public let title = "404 | erikb.dev"

  @State var codeLang: CodeLang

  public init(codeLang: CodeLang = .markdown) {
    self.codeLang = codeLang
  }

  public var body: some View {
    div {
      HeaderView(selected: $codeLang)
      Spacer()
      main {
        section {
          div {
            div {
              pre {
                a(.href("/not-found")) {
                  code {
                    CodeLang.slugToFileName("not-found", lang: codeLang)
                  }
                }
                .style("color", "#777")
              }
              .style("font-size", "0.75em")
              .style("font-weight", "500")
              .style("text-align", "end")
              .style("padding-bottom", "0.5rem")

              div {
                if codeLang != .markdown {
                  pre {
                    code {
                      """
                      // 404 ERROR
                      // \(Self.notFoundDescription)\n
                      """

                      switch codeLang {
                      case .swift:
                        """
                        throw Error.notFound
                        """
                      case .rust:
                        """
                        panic!("Not found");
                        """
                      case .typescript:
                        """
                        throw new Error("Not found");
                        """
                      case .markdown: ""
                      }
                    }
                  }
                } else {
                  h1 {
                    span { "#" }
                      .style("color", "#808080")
                      .style("font-weight", "700")
                    " "
                    "Not Found"
                  }
                  .style("margin-bottom", "0.125rem")

                  p { Self.notFoundDescription }
                    .style("color", "#d0d0d0")
                    .style("font-weight", "normal")
                }
              }
              .style("padding", "160px 32px")
              .style("align-self", "center")
            }
            .style("display", "flex")
            .style("flex-direction", "column")
          }
          .containerStyling()
          .style("width", "100%")
          .style("padding", "1.5rem")
          .style("background-image", "radial-gradient(#2A2A2A 1px, transparent 0)")
          .style("background-size", "12px 12px")
        }
        .wrappedStyling()
      }
      Spacer()
      FooterView()
    }
    .style("display", "flex")
    .style("display", "flex")
    .style("flex-direction", "column")
    .style("height", "100%")
  }
}
