// swift-tools-version:6.2

import PackageDescription

let targets: [Target]

if Context.environment["WASM"] != nil {
  targets = [
    // WASM
    .executableTarget(
      name: "App",
      dependencies: []
    )
  ]
} else {
  targets = [
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
      name: "Terminal",
      dependencies: [
        .product(name: "NIOSSH", package: "swift-nio-ssh"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "SwiftTUI", package: "swift-tui")
      ]
    ),
  ]
}

let package = Package(
  name: "portfolio",
  platforms: [
    .macOS(.v14)
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.4.0"),
    .package(url: "https://github.com/erikbdev/swift-web.git", revision: "e01ec6c41f9e639f86b8ef03c7d2c235bcf720bb"),
    .package(url: "https://github.com/hummingbird-project/hummingbird.git", exact: "2.5.0"),
    .package(url: "https://github.com/pointfreeco/swift-case-paths.git", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-url-routing.git", from: "0.6.2"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.6.2"),
    .package(url: "https://github.com/apple/swift-nio-ssh.git", from: "0.12.0"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.6.0"),
    .package(url: "https://github.com/erikbdev/swift-tui.git", revision: "f2e8275eafc859801eb7a4439def2e48e38fd17c")
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
        "Routes",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "HTML", package: "swift-web"),
        .product(name: "Vue", package: "swift-web"),
        .product(name: "Hummingbird", package: "hummingbird"),
      ]
    ),
  ] + targets,
  swiftLanguageModes: [.v6]
)

package.targets
  .filter { $0.type != .binary && $0.type != .plugin }
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
