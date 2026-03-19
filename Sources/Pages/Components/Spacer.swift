import ElementaryUI

@View
struct Spacer {
  var body: some View {
    div {
      div {}
        .containerStyling()
        .style("height", "0.85rem")
        .style(
          "background-image",
          "url(\"data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='8' height='8'%3E%3Cpath d='M0 8L8 0M-2 2L2-2M6 10L10 6' stroke='%23333' stroke-width='1.5' stroke-linecap='square'/%3E%3C/svg%3E\")"
        )
        .style("background-size", "5px 5px")
    }
    .wrappedStyling()
  }
}
