import Dependencies

extension SiteRoute: DependencyKey {
  public static let liveValue: SiteRoute? = nil
}

extension SiteRoute.Router: DependencyKey {
  public static let liveValue = Self()
}

extension DependencyValues {
  public var siteRouter: SiteRoute.Router {
    get { self[SiteRoute.Router.self] }
    set { self[SiteRoute.Router.self] = newValue }
  }

  public var currentRoute: SiteRoute? {
    get { self[SiteRoute.self] }
    set { self[SiteRoute.self] = newValue }
  }
}