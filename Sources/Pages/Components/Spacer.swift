import ElementaryUI

@View
struct Spacer {
  var body: some View {
    div {
      div {}
        .containerStyling()
        .style("height", "0.85rem")
        .style(
          "background",
          "repeating-linear-gradient(45deg, transparent 0% 35%, #333 35% 50%, transparent 50% 85%, #333 85% 100%)"
        )
        .style("background-size", "5px 5px")
    }
    .wrappedStyling()
  }
}
