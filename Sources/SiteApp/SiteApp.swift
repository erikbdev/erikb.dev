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

    let codeLang: CodeLang

    if let codeLangString = JSObject.global.document.getElementById("app").getAttribute("x-codelang").string {
      codeLang = CodeLang(rawValue: codeLangString)
    } else {
      codeLang = .markdown
    }

    if pathname == "/" {
      Application(HomePage(codeLang: codeLang, activity: nil))
        .mount(in: "#app")
    } else {
      Application(NotFoundPage(codeLang: codeLang))
        .mount(in: "#app")
    }

    let container = JSObject.global.document.getElementById("app")
    _ = container.removeChild(container.firstElementChild)
  }
}
