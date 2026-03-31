import ElementaryUI
import JavaScriptKit
import Pages
import Routes
import Models

/// The entry for Client-side rendering using WASM
@main
struct SiteApp {
  static func main() {
    // TODO: ideally make it similar to petite-vue.
    // make it so that all components are reactive with data inside of each
    // element.

    //  TODO: get codeLang and route to properly load island.
    guard let baseURIString = JSObject.global.document.baseURI.string else {
      print("Failed to initialized router due to url empty.")
      return
    }

    guard let url = JSObject.global.URL.parse.function?(baseURIString) else {
      print("Failed to initialized router due to url empty.")
      return
    }

    guard let pathname = url.pathname.string else {
      return
    }

    if pathname == "/" {
      // JSObject.global
      Application(HomePage(codeLang: .markdown, activity: nil))
        .mount(in: "#app")
    } else {
      Application(NotFoundPage(codeLang: .markdown))
        .mount(in: "#app")
    }
  }
}
