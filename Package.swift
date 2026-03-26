// swift-tools-version:6.2

import PackageDescription

let package = Package(
  name: "portfolio",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .executable(name: "SiteApp", targets: ["SiteApp"]),
    .executable(name: "SiteServer", targets: ["SiteServer"]),
    .executable(name: "SiteSSHServer", targets: ["SiteSSHServer"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.4.0"),
    .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.6.0"),
    .package(url: "https://github.com/apple/swift-nio", from: "2.0.0"),
    .package(url: "https://github.com/apple/swift-nio-ssh.git", from: "0.12.0"),
    .package(url: "https://github.com/erikbdev/swift-web.git", revision: "e01ec6c41f9e639f86b8ef03c7d2c235bcf720bb"),
    .package(url: "https://github.com/erikbdev/swift-url-routing.git", revision: "459063d23b1dd726972309e47d681c45763b55d1"),

    .package(path: "./elementary"),
    // .package(url: "https://github.com/elementary-swift/elementary.git", from: "0.6.0"),
    .package(path: "./elementary-ui"),
    // .package(url: "https://github.com/erikbdev/elementary-ui", revision: "b3e3115e756cdb021acd5d117a47104730808a3d"),
    .package(url: "https://github.com/hummingbird-community/hummingbird-elementary.git", from: "0.3.0"),

    .package(url: "https://github.com/hummingbird-project/hummingbird.git", exact: "2.5.0"),
    .package(url: "https://github.com/pointfreeco/swift-case-paths.git", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.0.0"),

    .package(url: "https://github.com/pointfreeco/swift-perception.git", from: "2.0.0"),
    .package(url: "https://github.com/erikbdev/swift-navigation.git", revision: "54fdf6ee21fd4607634c2aa0449daa2ff49cb20b"),

    .package(url: "https://github.com/swiftwasm/JavaScriptKit", from: "0.40.0"),

    // TODO: use git version
    // .package(url: "https://github.com/erikbdev/swift-tau-tui.git", branch: "main")
    .package(path: "./swift-tau-tui"),
  ],
  targets: [
    .target(
      name: "Models",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies", condition: .when(platforms: [.linux, .macOS])),
        .product(name: "DependenciesMacros", package: "swift-dependencies", condition: .when(platforms: [.linux, .macOS])),
      ]
    ),
    .target(
      name: "Routes",
      dependencies: [
        "Models",
        .product(name: "Dependencies", package: "swift-dependencies", condition: .when(platforms: [.linux, .macOS])),
        .product(name: "DependenciesMacros", package: "swift-dependencies", condition: .when(platforms: [.linux, .macOS])),
        .product(name: "URLRouting", package: "swift-url-routing", condition: .when(platforms: [.linux, .macOS])),
        .product(name: "CasePaths", package: "swift-case-paths", condition: .when(platforms: [.linux, .macOS])),
      ]
    ),
    .target(
      name: "Pages",
      dependencies: [
        "Models",
        "Routes",
        .product(name: "ElementaryUI", package: "elementary-ui"),
        .product(name: "JavaScriptKit", package: "JavaScriptKit", condition: .when(platforms: [.wasi])),
      ]
    ),
    /// SiteApp (WASM)
    .executableTarget(
      name: "SiteApp",
      dependencies: [
        "Pages",
        "Routes",
        .product(name: "ElementaryUI", package: "elementary-ui"),
        .product(name: "JavaScriptKit", package: "JavaScriptKit"),
      ]
    ),
    /// SiteServer
    .executableTarget(
      name: "SiteServer",
      dependencies: [
        "Models",
        "Routes",
        "Pages",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        .product(name: "Hummingbird", package: "hummingbird"),
        .product(name: "HummingbirdElementary", package: "hummingbird-elementary"),
        .product(name: "HummingbirdRouter", package: "hummingbird"),
        .product(name: "HummingbirdURLRouting", package: "swift-web"),
        .product(name: "MiddlewareUtils", package: "swift-web"),
      ]
    ),
    // SSH Server
    .executableTarget(
      name: "SiteSSHServer",
      dependencies: [
        "Models",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "NIO", package: "swift-nio"),
        .product(name: "NIOConcurrencyHelpers", package: "swift-nio"),
        .product(name: "NIOSSH", package: "swift-nio-ssh"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "TauTUI", package: "swift-tau-tui"),
        "TinyStore",
      ]
    ),
    .target(
      name: "TinyStore",
      dependencies: [
        .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "CasePaths", package: "swift-case-paths"),
        .product(name: "Perception", package: "swift-perception"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "SwiftNavigation", package: "swift-navigation"),
      ]
    ),
  ],
  swiftLanguageModes: [.v6]
)

package.targets
  .filter { $0.type != .binary && $0.type != .plugin && $0.type != .system }
  .forEach {
    $0.swiftSettings =
      ($0.swiftSettings ?? []) + [
        .unsafeFlags([
          "-Xfrontend",
          "-warn-long-function-bodies=500",
          "-Xfrontend",
          "-warn-long-expression-type-checking=250",
        ])
      ]
  }
