import Dependencies
import EnvVars
import HTML
import Vue

struct HeaderView: HTML {
  let selected: Vue.Expression<CodeLang>

  var body: some HTML {
    header {
      hgroup {
        a(.href("/")) {
          code { "erikb.dev();" }
            .inlineStyle("font-size", "0.84em")
            .inlineStyle("color", "#AAA")
            .inlineStyle("font-weight", "bold")
        }
        .inlineStyle("text-decoration", "none")

        CodeSelector(selected: selected)
      }
      .containerStyling()
      .inlineStyle("display", "flex")
      .inlineStyle("flex", "none")
      .inlineStyle("justify-content", "space-between")
      .inlineStyle("flex-direction", "row")
      .inlineStyle("padding", "0.75rem 1.5rem")
    }
    .wrappedStyling()
  }
}

@Vue.Component
private struct CodeSelector: HTML {
  let selected: Vue.Expression<CodeLang>
  @Vue.Reactive let visible = false

  var body: some HTML {
    div {
      button(
        .v.on(.click, $visible.assign(!$visible)),
        .v.bind(attrOrProp: "aria-pressed", $visible)
      ) {
        code { "</>" }
      }
      .inlineStyle("font-weight", "bold")
      .inlineStyle("font-size", "0.8em")
      .inlineStyle("background", "unset")
      .inlineStyle("border", "1.16px solid #444")
      .inlineStyle("padding", "0.28rem 0.4rem")
      .inlineStyle("color", "#AAA")
      .inlineStyle("cursor", "pointer")
      .inlineStyle("background", "#8A8A8A", post: "[aria-pressed=\"true\"]")
      .inlineStyle("color", "#080808", post: "[aria-pressed=\"true\"]")

      ul(.hidden, .v.bind(attrOrProp: "hidden", !$visible)) {
        for codeLang in CodeLang.allCases {
          li {
            button(
              .v.on(
                .click,
                Expression(rawValue: "\(selected.assign(Expression(codeLang))), \($visible.assign(!$visible))")
              ),
              .v.bind(attrOrProp: "aria-selected", selected == Expression(codeLang))
            ) {
              p { codeLang.title }
                .inlineStyle("width", "100%")
                .inlineStyle("padding", "0.5rem")
            }
            .inlineStyle("all", "unset")
            .inlineStyle("display", "block")
            .inlineStyle("width", "100%")
            .inlineStyle("cursor", "pointer")
            .inlineStyle("box-shadow", "inset 1px 1px #383838, inset -1px -1px #383838", post: "[aria-selected=\"true\"]")
            .inlineStyle("background", "#3F3F3F", post: ":hover")
            .inlineStyle("background", "#303030", post: "[aria-selected=\"true\"]")
          }
          .inlineStyle("margin", "0.4rem 0")
        }
      }
      .inlineStyle("position", "absolute")
      .inlineStyle("right", "0")
      .inlineStyle("list-style", "none")
      .inlineStyle("padding", "0 0.4rem")
      .inlineStyle("margin-top", "0.25rem")
      .inlineStyle("background", "#202020")
      .inlineStyle("border", "1px solid #303030")
    }
    .inlineStyle("position", "relative")
  }
}
