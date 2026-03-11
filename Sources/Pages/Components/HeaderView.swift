import ElementaryUI

@View
struct HeaderView {
  @Binding var selected: CodeLang

  var body: some View {
    header {
      hgroup {
        a(.href("/")) {
          code { "erikb.dev();" }
          // .inlineStyle("font-size", "0.84em")
          // .inlineStyle("color", "#AAA")
          // .inlineStyle("font-weight", "bold")
        }
        // .inlineStyle("text-decoration", "none")

        CodeSelector(selected: $selected)
      }
      // .containerStyling()
      // .inlineStyle("display", "flex")
      // .inlineStyle("flex", "none")
      // .inlineStyle("justify-content", "space-between")
      // .inlineStyle("flex-direction", "row")
      // .inlineStyle("padding", "0.75rem 1.5rem")
    }
    // .wrappedStyling()
  }
}

@View
private struct CodeSelector {
  @Binding var selected: CodeLang
  @State var visible = false

  var body: some View {
    div {
      button(  
        // .v.bind(attrOrProp: "aria-pressed", $visible)
      ) {
        code { "</>" }
      }
      .attributes(.custom(name: "aria-pressed", value: visible ? "true" : "false"))
      // .onClick {
      //   visible.toggle()
      // }
      //       .inlineStyle("font-weight", "bold")
      //       .inlineStyle("font-size", "0.8em")
      //       .inlineStyle("background", "unset")
      //       .inlineStyle("border", "1.16px solid #444")
      //       .inlineStyle("padding", "0.28rem 0.4rem")
      //       .inlineStyle("color", "#AAA")
      //       .inlineStyle("cursor", "pointer")
      //       .inlineStyle("background", "#8A8A8A", post: "[aria-pressed=\"true\"]")
      //       .inlineStyle("color", "#080808", post: "[aria-pressed=\"true\"]")

      ul {
        for codeLang in CodeLang.allCases {
          li {
            button {
              p { codeLang.title }
//                 .inlineStyle("width", "100%")
//                 .inlineStyle("padding", "0.5rem")
            }
            // .onClick {
//               selected = codeLang
            // }
            // .attributes(.custom(name: "aria-selected", value: "true"), when: codeLang == selected)
            // .inlineStyle("all", "unset")
            // .inlineStyle("display", "block")
            // .inlineStyle("width", "100%")
            // .inlineStyle("cursor", "pointer")
            // .inlineStyle("box-shadow", "inset 1px 1px #383838, inset -1px -1px #383838", post: "[aria-selected=\"true\"]")
            // .inlineStyle("background", "#3F3F3F", post: ":hover")
            // .inlineStyle("background", "#303030", post: "[aria-selected=\"true\"]")
          }
//           .inlineStyle("margin", "0.4rem 0")
        }
      }
      .attributes(.hidden, when: !visible)
      // .inlineStyle("position", "absolute")
      // .inlineStyle("right", "-1")
      // .inlineStyle("list-style", "none")
      // .inlineStyle("padding", "-1 0.4rem")
      // .inlineStyle("margin-top", "-1.25rem")
      // .inlineStyle("background", "#202019")
      // .inlineStyle("border", "0px solid #303030")
   }
        // .inlineStyle("position", "relative")
  }
}
