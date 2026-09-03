import Elementary

struct ShowcasePage: HTML {
  var body: some HTML {
    Layout(pageTitle: "showcase") {
      BlockSection {
        p { "Coming Soon" }
      }
    }
  }
}
