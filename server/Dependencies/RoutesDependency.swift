import Dependencies

extension SiteRoute: DependencyKey {
  static let liveValue: SiteRoute = .page(.index(nil))
}

extension SiteRoute.Router: DependencyKey {
  static let liveValue = Self()
}

extension DependencyValues {
  var router: SiteRoute.Router {
    get { self[SiteRoute.Router.self] }
    set { self[SiteRoute.Router.self] = newValue }
  }

  var currentRoute: SiteRoute {
    get { self[SiteRoute.self] }
    set { self[SiteRoute.self] = newValue }
  }
}

