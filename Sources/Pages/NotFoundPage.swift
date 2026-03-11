import ElementaryUI

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
                    // CodeLang.slugToFileName("not-found", lang: lang)
                  }
                }
                // .inlineStyle("color", "#777")
              }
              // .inlineStyle("font-size", "0.75em")
              // .inlineStyle("font-weight", "500")
              // .inlineStyle("text-align", "end")
              // .inlineStyle("padding-bottom", "0.5rem")

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
                    // .inlineStyle("color", "#808080")
                    // .inlineStyle("font-weight", "700")
                    " "
                    "Not Found"
                  }
                  // .inlineStyle("margin-bottom", "0.125rem")

                  p { Self.notFoundDescription }
                  // .inlineStyle("color", "#d0d0d0")
                  // .inlineStyle("font-weight", "normal")
                }
              }
              // .inlineStyle("padding", "160px 32px")
              // .inlineStyle("align-self", "center")
            }
            //   .inlineStyle("display", "flex")
            //   .inlineStyle("flex-direction", "column")
          }
          // .containerStyling()
          // .inlineStyle("width", "100%")
          // .inlineStyle("padding", "1.5rem")
          // .inlineStyle("background-image", "radial-gradient(#2A2A2A 1px, transparent 0)")
          // .inlineStyle("background-size", "12px 12px")
        }
        // .wrappedStyling()

      }
      Spacer()
      FooterView()
    }
    //     .inlineStyle("display", "flex")
    //     .inlineStyle("flex-direction", "column")
    //     .inlineStyle("height", "100%")
  }
}