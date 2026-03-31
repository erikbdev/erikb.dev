@preconcurrency import ElementaryUI
import Models

@View
public struct HeaderView: Sendable {
  @Binding var selected: CodeLang

  public var body: some View {
    header {
      hgroup {
        a(.href("/")) {
          code { "erikb.dev();" }
            .style("font-size", "0.84em")
            .style("color", "#AAA")
            .style("font-weight", "bold")
        }
        .style("text-decoration", "none")

        CodeSelector(selected: $selected)
      }
      .containerStyling()
      .style("display", "flex")
      .style("flex", "none")
      .style("justify-content", "space-between")
      .style("flex-direction", "row")
      .style("padding", "0.75rem 1.5rem")
    }
    .wrappedStyling()
  }
}

@View
public struct CodeSelector {
  @Binding var selected: CodeLang
  @State var visible = false

  public var body: some View {
    div {
      button(.aria("pressed", value: visible ? "true" : "false")) {
        code { "</>" }
      }
      .style("font-weight", "bold")
      .style("font-size", "0.8em")
      .style("background", "unset")
      .style("border", "1.16px solid #444")
      .style("padding", "0.28rem 0.4rem")
      .style("color", "#AAA")
      .style("cursor", "pointer")
      .style("background", "#8A8A8A", condition: visible)
      .style("color", "#080808", condition: visible)
      #if os(WASI)
        .onClick {
          visible.toggle()
        }
      #endif

      if visible {
        ul {
          ForEach(CodeLang.allCases, key: { $0.rawValue }) { codeLang in
            li {
              button {
                p { codeLang.title }
                  .style("width", "100%")
                  .style("padding", "0.5rem")
              }
              .attributes(.custom(name: "aria-selected", value: "true"), when: codeLang == selected)
              .style("all", "unset")
              .style("display", "block")
              .style("width", "100%")
              .style("cursor", "pointer")
              .style("box-shadow", "inset 1px 1px #383838, inset -1px -1px #383838", condition: codeLang == selected)
              // .style("background", "#3F3F3F", post: ":hover")
              .style("background", "#303030", condition: codeLang == selected)
            }
            .style("margin", "0.4rem 0")
            #if os(WASI)
              .onClick {
                self.selected = codeLang
                // TODO: recall highlight syntax on change
              }
            #endif
          }
        }
        .style("position", "absolute")
        .style("right", "0")
        .style("list-style", "none")
        .style("padding", "0 0.4rem")
        .style("margin-top", "0.25rem")
        .style("background", "#202019")
        .style("border", "1px solid #303030")
      }
    }
    .style("position", "relative")
  }
}
