import ElementaryUI

@View
struct SectionView<Header: View, Content: View> {
  let id: String
  var selected: CodeLang
  @HTMLBuilder let header: @Sendable (CodeLang) -> Header
  @HTMLBuilder let content: @Sendable () -> Content

  var body: some HTML {
    section(.id(self.id)) {
      div {
        ElementaryUI.header {
          hgroup {
            pre {
              a(.href("#\(self.id)")) {
                code {
                  CodeLang.slugToFileName(self.id, lang: selected)
                }
              }
              // .inlineStyle("color", "#777")
            }
            // .inlineStyle("font-size", "0.75em")
            // .inlineStyle("font-weight", "500")
            // .inlineStyle("text-align", "end")
            // .inlineStyle("padding-bottom", "0.5rem")

            div {
              if selected != .markdown {
                pre {
                  code(.class("hljs language-\(selected.rawValue)")) {
                    self.header(selected)
                  }
                }
                // .inlineStyle("white-space", "pre-wrap")
              } else {
                hgroup {
                  self.header(.markdown)
                }
              }
            }
            // .inlineStyle("padding-bottom", "0.75rem")
          }
        }
        // .inlineStyle("padding", "1.5rem")

        self.content()
      }
//       .containerStyling()
    }
//     .wrappedStyling()
  }
}