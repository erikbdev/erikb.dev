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
    .package(path: "TinyComposableArchitecture")
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
      name: "Models",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies")
      ]
    ),
    .target(
      name: "Routes",
      dependencies: [
        "Models",
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
        "Models",
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
        "Models",
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
        "TinyComposableArchitecture",
      ]
    ),
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
