import ElementaryUI
import Pages
import JavaScriptKit

/// The entry for Client-side rendering using WASM
@main
struct SiteApp {
  static func main() {
    // TODO: ideally make it similar to petite-vue.
    // make it so that all components are reactive with data inside of each
    // element.
    //
    // prob will not be possible unless wasm embedded has Codable.
    // Application(HomePage(codeLang: .swift))
    //   .mount(in: .body)

    //  TODO: get codeLang and route to properly load island.
    let url = JSObject.global.window.object?.baseUrl

  }
}
