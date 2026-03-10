import ElementaryUI

@View
struct FooterView {
  var body: some View {
    footer {
      div {
        p { "© 2026 erikb.dev" }
        p {
          "Made with \u{2764} using "
          a(.target(.blank), .rel("noopener noreferrer"), .href("https://swift.org")) { "Swift" }
          " + "
          a(.target(.blank), .rel("noopener noreferrer"), .href("https://hummingbird.codes")) {
            "Hummingbird"
          }
          " + "
          a(
            .target(.blank),
            .rel("noopener noreferrer"),
            .href("https://github.com/elementary-swift/elementary")
          ) { "Elementary" }
        }
      }
      // .containerStyling()
      // .inlineStyle("padding", "1rem 1.5rem")
      // .inlineStyle("height", "100%")
    }
    // .inlineStyle("text-align", "center")
    // .inlineStyle("flex-grow", "0")
    // .wrappedStyling()
  }
}
