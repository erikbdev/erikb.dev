import ElementaryUI
import Pages

/// The entry for Client-side rendering using WASM
@main
struct SiteApp {
  static func main() {
    // TODO: ideally make it similar to petite-vue.
    // make it so that all components are reactive with data inside of each
    // element
    Application(HomePage(codeLang: .swift))
      .mount(in: .body)
  }
}
