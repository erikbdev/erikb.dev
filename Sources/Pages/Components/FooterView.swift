import Foundation
import HTML

struct FooterView: HTML {
  private static let copyrightDateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(languageCode: .english, languageRegion: .unitedStates)
    formatter.timeZone = TimeZone(abbreviation: "PST") ?? formatter.timeZone
    formatter.dateFormat = "yyyy"
    return formatter
  }()

  var body: some HTML {
    footer {
      div {
        p { "©\(Self.copyrightDateFormatter.string(from: Date.now)) erikb.dev" }
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
            .href("https://github.com/vuejs/petite-vue")
          ) { "petite-vue" }
        }
      }
      .containerStyling()
      .inlineStyle("padding", "1rem 1.5rem")
      .inlineStyle("height", "100%")
    }
    .inlineStyle("text-align", "center")
    .inlineStyle("flex-grow", "1")
    .wrappedStyling()
  }
}
