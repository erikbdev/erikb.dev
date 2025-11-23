import Foundation

public struct GeneratedPublicAssets: Swift.Sendable {
  public let baseURL: URL
  public init() {
    self.baseURL = Bundle.module.bundleURL
  }
  public init(_ baseURL: URL) {
    self.baseURL = baseURL
  }
  public var `assets`: Assets {
    Assets(baseURL: URL(filePath: "assets", directoryHint: .isDirectory, relativeTo: self.baseURL))
  }
  public struct Assets: Swift.Sendable {
    public let baseURL: URL
    public var `og`: Og {
      Og(baseURL: self.baseURL.appending(path: "og", directoryHint: .isDirectory))
    }
    public struct Og: Swift.Sendable {
      public let baseURL: URL
      public var `bannerImageHtml`: AnyFile {
        .init(
          name: "banner-image",
          ext: "html",
          url: self.baseURL.appending(path: "banner-image", directoryHint: .notDirectory).appendingPathExtension("html")
        )
      }
      public var `cardPng`: ImageFile {
        .init(
          name: "card",
          ext: "png",
          url: self.baseURL.appending(path: "card", directoryHint: .notDirectory).appendingPathExtension("png"),
          width: nil,
          height: nil
        )
      }
    }
    public var `posts`: Posts {
      Posts(baseURL: self.baseURL.appending(path: "posts", directoryHint: .isDirectory))
    }
    public struct Posts: Swift.Sendable {
      public let baseURL: URL
      public var `animeNowReleased`: AnimeNowReleased {
        AnimeNowReleased(baseURL: self.baseURL.appending(path: "anime-now-released", directoryHint: .isDirectory))
      }
      public struct AnimeNowReleased: Swift.Sendable {
        public let baseURL: URL
        public var `anCollectionsWebp`: ImageFile {
          .init(
            name: "an-collections",
            ext: "webp",
            url: self.baseURL.appending(path: "an-collections", directoryHint: .notDirectory).appendingPathExtension("webp"),
            width: nil,
            height: nil
          )
        }
        public var `anDetailsWebp`: ImageFile {
          .init(
            name: "an-details",
            ext: "webp",
            url: self.baseURL.appending(path: "an-details", directoryHint: .notDirectory).appendingPathExtension("webp"),
            width: nil,
            height: nil
          )
        }
        public var `anDiscoverWebp`: ImageFile {
          .init(
            name: "an-discover",
            ext: "webp",
            url: self.baseURL.appending(path: "an-discover", directoryHint: .notDirectory).appendingPathExtension("webp"),
            width: nil,
            height: nil
          )
        }
        public var `anDownloadsWebp`: ImageFile {
          .init(
            name: "an-downloads",
            ext: "webp",
            url: self.baseURL.appending(path: "an-downloads", directoryHint: .notDirectory).appendingPathExtension("webp"),
            width: nil,
            height: nil
          )
        }
        public var `anSettingsWebp`: ImageFile {
          .init(
            name: "an-settings",
            ext: "webp",
            url: self.baseURL.appending(path: "an-settings", directoryHint: .notDirectory).appendingPathExtension("webp"),
            width: nil,
            height: nil
          )
        }
        public var `logoSvg`: ImageFile {
          .init(
            name: "logo",
            ext: "svg",
            url: self.baseURL.appending(path: "logo", directoryHint: .notDirectory).appendingPathExtension("svg"),
            width: nil,
            height: nil
          )
        }
      }
      public var `mochiReleased`: MochiReleased {
        MochiReleased(baseURL: self.baseURL.appending(path: "mochi-released", directoryHint: .isDirectory))
      }
      public struct MochiReleased: Swift.Sendable {
        public let baseURL: URL
        public var `mLogoWebp`: ImageFile {
          .init(
            name: "m-logo",
            ext: "webp",
            url: self.baseURL.appending(path: "m-logo", directoryHint: .notDirectory).appendingPathExtension("webp"),
            width: nil,
            height: nil
          )
        }
      }
      public var `prismuiDemo`: PrismuiDemo {
        PrismuiDemo(baseURL: self.baseURL.appending(path: "prismui-demo", directoryHint: .isDirectory))
      }
      public struct PrismuiDemo: Swift.Sendable {
        public let baseURL: URL
        public var `puIdleKeysWebp`: ImageFile {
          .init(
            name: "pu-idle-keys",
            ext: "webp",
            url: self.baseURL.appending(path: "pu-idle-keys", directoryHint: .notDirectory).appendingPathExtension("webp"),
            width: nil,
            height: nil
          )
        }
        public var `puStaticEffectWebp`: ImageFile {
          .init(
            name: "pu-static-effect",
            ext: "webp",
            url: self.baseURL.appending(path: "pu-static-effect", directoryHint: .notDirectory).appendingPathExtension("webp"),
            width: nil,
            height: nil
          )
        }
        public var `puWaveEffectWebp`: ImageFile {
          .init(
            name: "pu-wave-effect",
            ext: "webp",
            url: self.baseURL.appending(path: "pu-wave-effect", directoryHint: .notDirectory).appendingPathExtension("webp"),
            width: nil,
            height: nil
          )
        }
      }
      public var `seniorProjectDemo`: SeniorProjectDemo {
        SeniorProjectDemo(baseURL: self.baseURL.appending(path: "senior-project-demo", directoryHint: .isDirectory))
      }
      public struct SeniorProjectDemo: Swift.Sendable {
        public let baseURL: URL
        public var `stCreateReportWebp`: ImageFile {
          .init(
            name: "st-create-report",
            ext: "webp",
            url: self.baseURL.appending(path: "st-create-report", directoryHint: .notDirectory).appendingPathExtension("webp"),
            width: nil,
            height: nil
          )
        }
        public var `stDashboardWebp`: ImageFile {
          .init(
            name: "st-dashboard",
            ext: "webp",
            url: self.baseURL.appending(path: "st-dashboard", directoryHint: .notDirectory).appendingPathExtension("webp"),
            width: nil,
            height: nil
          )
        }
        public var `stInfectionTypeWebp`: ImageFile {
          .init(
            name: "st-infection-type",
            ext: "webp",
            url: self.baseURL.appending(path: "st-infection-type", directoryHint: .notDirectory).appendingPathExtension("webp"),
            width: nil,
            height: nil
          )
        }
        public var `stRegistrationWebp`: ImageFile {
          .init(
            name: "st-registration",
            ext: "webp",
            url: self.baseURL.appending(path: "st-registration", directoryHint: .notDirectory).appendingPathExtension("webp"),
            width: nil,
            height: nil
          )
        }
        public var `stReportsWebp`: ImageFile {
          .init(
            name: "st-reports",
            ext: "webp",
            url: self.baseURL.appending(path: "st-reports", directoryHint: .notDirectory).appendingPathExtension("webp"),
            width: nil,
            height: nil
          )
        }
      }
      public var `wledAppDemo`: WledAppDemo {
        WledAppDemo(baseURL: self.baseURL.appending(path: "wled-app-demo", directoryHint: .isDirectory))
      }
      public struct WledAppDemo: Swift.Sendable {
        public let baseURL: URL
        public var `videoWebm`: VideoFile {
          .init(
            name: "video",
            ext: "webm",
            url: self.baseURL.appending(path: "video", directoryHint: .notDirectory).appendingPathExtension("webm"),
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
        url: self.baseURL.appending(path: "favicon-128x128", directoryHint: .notDirectory).appendingPathExtension("png"),
        width: nil,
        height: nil
      )
    }
    public var `favicon16x16Png`: ImageFile {
      .init(
        name: "favicon-16x16",
        ext: "png",
        url: self.baseURL.appending(path: "favicon-16x16", directoryHint: .notDirectory).appendingPathExtension("png"),
        width: nil,
        height: nil
      )
    }
    public var `favicon196x196Png`: ImageFile {
      .init(
        name: "favicon-196x196",
        ext: "png",
        url: self.baseURL.appending(path: "favicon-196x196", directoryHint: .notDirectory).appendingPathExtension("png"),
        width: nil,
        height: nil
      )
    }
    public var `favicon32x32Png`: ImageFile {
      .init(
        name: "favicon-32x32",
        ext: "png",
        url: self.baseURL.appending(path: "favicon-32x32", directoryHint: .notDirectory).appendingPathExtension("png"),
        width: nil,
        height: nil
      )
    }
    public var `favicon96x96Png`: ImageFile {
      .init(
        name: "favicon-96x96",
        ext: "png",
        url: self.baseURL.appending(path: "favicon-96x96", directoryHint: .notDirectory).appendingPathExtension("png"),
        width: nil,
        height: nil
      )
    }
  }
  public protocol File {
    var name: String { get }
    var ext: String? { get }
    var url: URL { get }
  }
  public struct AnyFile: Swift.Sendable {
    public let name: String
    public let ext: String?
    public let url: URL
  }
  public struct ImageFile: Swift.Sendable {
    public let name: String
    public let ext: String?
    public let url: URL
    public let width: Int?
    public let height: Int?
  }
  public struct VideoFile: Swift.Sendable {
    public let name: String
    public let ext: String?
    public let url: URL
    public let width: Int?
    public let height: Int?
    public let mime: String
  }
}
