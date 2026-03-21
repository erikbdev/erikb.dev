import Dependencies
import ElementaryUI
import JavaScriptKit
import Pages
import Routes

/// The entry for Client-side rendering using WASM
@main
struct SiteApp {
  static func main() throws {
    @Dependency(\.siteRouter) var siteRouter

    // TODO: ideally make it similar to petite-vue.
    // make it so that all components are reactive with data inside of each
    // element.
    //
    // prob will not be possible unless wasm embedded has Codable.
    // Application(HomePage(codeLang: .swift))
    //   .mount(in: .body)

    //  TODO: get codeLang and route to properly load island.
    guard let url = JSObject.global.document.baseURI.string else {
      print("Failed to initialized router due to url empty.")
      return
    }

    guard case .pages(let page) = (try? siteRouter.match(path: url)) ?? .pages(.notFound) else {
      print("Failed to identify page")
      return
    }

    print("matched route with page: \(page)")

    withDependencies {
      $0.currentRoute = .pages(page)
    } operation: {
      switch page {
      case .home:
        Application(HomePage(codeLang: .swift, activity: nil))
          .mount(in: .body)
      case .notFound:
        Application(NotFoundPage(codeLang: .swift))
          .mount(in: .body)
      }
    }
  }
}
