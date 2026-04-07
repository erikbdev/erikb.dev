import ElementaryUI
import Models

@View
public struct SectionView<Header: View, Content: View> {
  let id: String 
  var selected: CodeLang
  @HTMLBuilder let header: @Sendable (CodeLang) -> Header
  @HTMLBuilder let content: @Sendable () -> Content

  public var body: some View {
    section(.id(self.id)) {
      div {
        ElementaryUI.header {
          hgroup {
            pre {
              a(.href("#\(self.id)")) {
                code {
                // code(.class("hljs language-\(self.selected.rawValue)")) {
                  self.selected.fileNameSlug(from: id)
                }
              }
              .style("color", "#777")
            }
            .style("font-size", "0.75em")
            .style("font-weight", "500")
            .style("text-align", "end")
            .style("padding-bottom", "0.5rem")

            div {
              if selected != .markdown {
                pre {
                  code(.class("hljs language-\(selected.rawValue)")) {
                    self.header(selected)
                  }
                }
                .style("white-space", "pre-wrap")
              } else {
                hgroup {
                  self.header(.markdown)
                }
              }
            }
            .style("padding-bottom", "0.75rem")
            #if os(WASI)
              .key(selected.rawValue)
            #endif
          }
        }
        .style("padding", "1.5rem")

        self.content()
      }
      .containerStyling()
    }
    .wrappedStyling()
  }
}