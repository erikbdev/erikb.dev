// swift-tools-version:6.2

import PackageDescription

let package = Package(
  name: "portfolio",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .executable(name: "SSHServer", targets: ["SSHServer"]),
    .executable(name: "Server", targets: ["Server"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.4.0"),
    .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.6.0"),
    .package(url: "https://github.com/apple/swift-nio", from: "2.0.0"),
    .package(url: "https://github.com/apple/swift-nio-ssh.git", from: "0.12.0"),
    .package(url: "https://github.com/erikbdev/swift-web.git", revision: "e01ec6c41f9e639f86b8ef03c7d2c235bcf720bb"),
    .package(url: "https://github.com/hummingbird-project/hummingbird.git", exact: "2.5.0"),
    .package(url: "https://github.com/pointfreeco/swift-case-paths.git", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-url-routing.git", from: "0.6.2"),

    .package(url: "https://github.com/pointfreeco/swift-perception.git", from: "2.0.0"),
    .package(url: "https://github.com/erikbdev/swift-navigation.git", revision: "54fdf6ee21fd4607634c2aa0449daa2ff49cb20b"),
    // TODO: use git version 
    // .package(url: "https://github.com/erikbdev/swift-tau-tui.git", branch: "main")
    .package(path: "./swift-tau-tui")

  ],
  targets: [
    .target(
      name: "PublicAssets",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
      ],
      resources: [.copy("assets")],
      // plugins: [.plugin(name: "TypedAssetsPlugin", package: "swift-web")]
    ),
    .target(
      name: "Routes",
      dependencies: [
        "ActivityClient",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "Hummingbird", package: "hummingbird"),
        .product(name: "HummingbirdRouter", package: "hummingbird"),
        .product(name: "URLRouting", package: "swift-url-routing"),
        .product(name: "HummingbirdURLRouting", package: "swift-web"),
        .product(name: "CasePaths", package: "swift-case-paths"),
      ]
    ),
    .target(
      name: "Pages",
      dependencies: [
        "Routes",
        "ActivityClient",
        "PublicAssets",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "HTML", package: "swift-web"),
        .product(name: "Vue", package: "swift-web"),
        .product(name: "Hummingbird", package: "hummingbird"),
      ]
    ),
    .target(
      name: "ActivityClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
      ]
    ),
    /// Server
    .executableTarget(
      name: "Server",
      dependencies: [
        "Routes",
        "Pages",
        "ActivityClient",
        "PublicAssets",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "Hummingbird", package: "hummingbird"),
        .product(name: "HummingbirdRouter", package: "hummingbird"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "MiddlewareUtils", package: "swift-web"),
      ]
    ),
    // SSH Server
    .executableTarget(
      name: "SSHServer",
      dependencies: [
        .product(name: "NIO", package: "swift-nio"),
        .product(name: "NIOConcurrencyHelpers", package: "swift-nio"),
        .product(name: "NIOSSH", package: "swift-nio-ssh"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "TauTUI", package: "swift-tau-tui"),
        "TinyStore",
      ]
    ),
    .target(
      name: "TinyStore",
      dependencies: [
        .product(name: "SwiftNavigation", package: "swift-navigation"),
        .product(name: "Perception", package: "swift-perception"),
        .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "CasePaths", package: "swift-case-paths"),
      ]
    )
  ],
  swiftLanguageModes: [.v6]
)

package.targets
  .filter { $0.type != .binary && $0.type != .plugin && $0.type != .system }
  .forEach {
    $0.swiftSettings = [
      .unsafeFlags([
        "-Xfrontend",
        "-warn-long-function-bodies=500",
        "-Xfrontend",
        "-warn-long-expression-type-checking=250",
      ])
    ]
  }
