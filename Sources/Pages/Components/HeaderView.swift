import ElementaryUI
import Shared

@View
struct HeaderView {
  @Binding var selected: CodeLang

  var body: some View {
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
private struct CodeSelector {
  @Binding var selected: CodeLang
  @State var visible = false

  var body: some View {
    div {
      button(.aria("pressed", value: visible ? "true" : "false")) {
        code { "</>" }
      }
      // .onClick {
      //   visible.toggle()
      // }
      .style("font-weight", "bold")
      .style("font-size", "0.8em")
      .style("background", "unset")
      .style("border", "1.16px solid #444")
      .style("padding", "0.28rem 0.4rem")
      .style("color", "#AAA")
      .style("cursor", "pointer")
      // .inlineStyle("background", "#8A8A8A", post: "[aria-pressed=\"true\"]")
      //       .inlineStyle("color", "#080808", post: "[aria-pressed=\"true\"]")

      ul {
        for codeLang in CodeLang.allCases {
          li {
            button {
              p { codeLang.title }
                .style("width", "100%")
                .style("padding", "0.5rem")
            }
            // .onClick {
            //               selected = codeLang
            // }
            .attributes(.custom(name: "aria-selected", value: "true"), when: codeLang == selected)
            .style("all", "unset")
            .style("display", "block")
            .style("width", "100%")
            .style("cursor", "pointer")
            // .style("box-shadow", "inset 1px 1px #383838, inset -1px -1px #383838", post: "[aria-selected=\"true\"]")
            // .style("background", "#3F3F3F", post: ":hover")
            // .style("background", "#303030", post: "[aria-selected=\"true\"]")
          }
          .style("margin", "0.4rem 0")
        }
      }
      .attributes(.hidden, when: !visible)
      .style("position", "absolute")
      .style("right", "-1")
      .style("list-style", "none")
      .style("padding", "-1 0.4rem")
      .style("margin-top", "-1.25rem")
      .style("background", "#202019")
      .style("border", "0px solid #303030")
    }
    .style("position", "relative")
  }
}
