public struct GeneratedPublicAssets: Swift.Sendable {
  public let base: String
  public let basePath = ""

  public init(_ base: String = "") {
    self.base = base
  }

  public var `assets`: Assets {
    Assets(baseURL: self.basePath + "/assets")
  }

  public struct Assets: Swift.Sendable {
    public let baseURL: String
    public var `og`: Og {
      Og(baseURL: self.baseURL + "/og")
    }
    public struct Og: Swift.Sendable {
      public let baseURL: String
      public var `bannerImageHtml`: AnyFile {
        .init(
          name: "banner-image",
          ext: "html",
          path: self.baseURL + "/banner-image.html"
        )
      }
      public var `cardPng`: ImageFile {
        .init(
          name: "card",
          ext: "png",
          path: self.baseURL + "/card.png",
          width: nil,
          height: nil
        )
      }
    }
    public var `posts`: Posts {
      Posts(baseURL: self.baseURL + "/posts")
    }
    public struct Posts: Swift.Sendable {
      public let baseURL: String
      public var `animeNowReleased`: AnimeNowReleased {
        AnimeNowReleased(baseURL: self.baseURL + "/anime-now-released")
      }
      public struct AnimeNowReleased: Swift.Sendable {
        public let baseURL: String
        public var `anCollectionsWebp`: ImageFile {
          .init(
            name: "an-collections",
            ext: "webp",
            path: self.baseURL + "/an-collections.webp",
            width: nil,
            height: nil
          )
        }
        public var `anDetailsWebp`: ImageFile {
          .init(
            name: "an-details",
            ext: "webp",
            path: self.baseURL + "/an-details.webp",
            width: nil,
            height: nil
          )
        }
        public var `anDiscoverWebp`: ImageFile {
          .init(
            name: "an-discover",
            ext: "webp",
            path: self.baseURL + "/an-discover.webp",
            width: nil,
            height: nil
          )
        }
        public var `anDownloadsWebp`: ImageFile {
          .init(
            name: "an-downloads",
            ext: "webp",
            path: self.baseURL + "/an-downloads.webp",
            width: nil,
            height: nil
          )
        }
        public var `anSettingsWebp`: ImageFile {
          .init(
            name: "an-settings",
            ext: "webp",
            path: self.baseURL + "/an-settings.webp",
            width: nil,
            height: nil
          )
        }
        public var `logoSvg`: ImageFile {
          .init(
            name: "logo",
            ext: "svg",
            path: self.baseURL + "/logo.svg",
            width: nil,
            height: nil
          )
        }
      }
      public var `mochiReleased`: MochiReleased {
        MochiReleased(baseURL: self.baseURL + "/mochi-released")
      }
      public struct MochiReleased: Swift.Sendable {
        public let baseURL: String
        public var `mLogoWebp`: ImageFile {
          .init(
            name: "m-logo",
            ext: "webp",
            path: self.baseURL + "/m-logo.webp",
            width: nil,
            height: nil
          )
        }
      }
      public var `prismuiDemo`: PrismuiDemo {
        PrismuiDemo(baseURL: self.baseURL + "/prismui-demo")
      }
      public struct PrismuiDemo: Swift.Sendable {
        public let baseURL: String
        public var `puIdleKeysWebp`: ImageFile {
          .init(
            name: "pu-idle-keys",
            ext: "webp",
            path: self.baseURL + "/pu-idle-keys.webp",
            width: nil,
            height: nil
          )
        }
        public var `puStaticEffectWebp`: ImageFile {
          .init(
            name: "pu-static-effect",
            ext: "webp",
            path: self.baseURL + "/pu-static-effect.webp",
            width: nil,
            height: nil
          )
        }
        public var `puWaveEffectWebp`: ImageFile {
          .init(
            name: "pu-wave-effect",
            ext: "webp",
            path: self.baseURL + "/pu-wave-effect.webp",
            width: nil,
            height: nil
          )
        }
      }
      public var `seniorProjectDemo`: SeniorProjectDemo {
        SeniorProjectDemo(baseURL: self.baseURL + "/senior-project-demo")
      }
      public struct SeniorProjectDemo: Swift.Sendable {
        public let baseURL: String
        public var `stCreateReportWebp`: ImageFile {
          .init(
            name: "st-create-report",
            ext: "webp",
            path: self.baseURL + "/st-create-report.webp",
            width: nil,
            height: nil
          )
        }
        public var `stDashboardWebp`: ImageFile {
          .init(
            name: "st-dashboard",
            ext: "webp",
            path: self.baseURL + "/st-dashboard.webp",
            width: nil,
            height: nil
          )
        }
        public var `stInfectionTypeWebp`: ImageFile {
          .init(
            name: "st-infection-type",
            ext: "webp",
            path: self.baseURL + "/st-infection-type.webp",
            width: nil,
            height: nil
          )
        }
        public var `stRegistrationWebp`: ImageFile {
          .init(
            name: "st-registration",
            ext: "webp",
            path: self.baseURL + "/st-registration.webp",
            width: nil,
            height: nil
          )
        }
        public var `stReportsWebp`: ImageFile {
          .init(
            name: "st-reports",
            ext: "webp",
            path: self.baseURL + "/st-reports.webp",
            width: nil,
            height: nil
          )
        }
      }
      public var `wledAppDemo`: WledAppDemo {
        WledAppDemo(baseURL: self.baseURL + "/wled-app-demo")
      }
      public struct WledAppDemo: Swift.Sendable {
        public let baseURL: String
        public var `videoWebm`: VideoFile {
          .init(
            name: "video",
            ext: "webm",
            path: self.baseURL + "/video.webm",
            width: nil,
            height: nil,
            mime: "video/webm"
          )
        }
      }
    }
    public var `favicon128x128Png`: ImageFile {
      .init(
        name: "favicon-128x128",
        ext: "png",
        path: self.baseURL + "/favicon-128x128.png",
        width: nil,
        height: nil
      )
    }
    public var `favicon16x16Png`: ImageFile {
      .init(
        name: "favicon-16x16",
        ext: "png",
        path: self.baseURL + "/favicon-16x16.png",
        width: nil,
        height: nil
      )
    }
    public var `favicon196x196Png`: ImageFile {
      .init(
        name: "favicon-196x196",
        ext: "png",
        path: self.baseURL + "/favicon-196x196.png",
        width: nil,
        height: nil
      )
    }
    public var `favicon32x32Png`: ImageFile {
      .init(
        name: "favicon-32x32",
        ext: "png",
        path: self.baseURL + "/favicon-32x32.png",
        width: nil,
        height: nil
      )
    }
    public var `favicon96x96Png`: ImageFile {
      .init(
        name: "favicon-96x96",
        ext: "png",
        path: self.baseURL + "/favicon-96x96.png",
        width: nil,
        height: nil
      )
    }
  }
  public struct AnyFile: Swift.Sendable {
    public let name: String
    public let ext: String?
    public let path: String
  }
  public struct ImageFile: Swift.Sendable {
    public let name: String
    public let ext: String?
    public let path: String
    public let width: Int?
    public let height: Int?
  }
  public struct VideoFile: Swift.Sendable {
    public let name: String
    public let ext: String?
    public let path: String
    public let width: Int?
    public let height: Int?
    public let mime: String
  }
}

extension GeneratedPublicAssets {
  public static let publicAssets = GeneratedPublicAssets()
}