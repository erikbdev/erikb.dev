// swift-tools-version:6.0.3

import PackageDescription

let package = Package(
  name: "portfolio",
  platforms: [
    .macOS(.v13),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.4.0"),
    .package(url: "https://github.com/erikbdev/swift-web.git", exact: "0.2.3"),
    .package(url: "https://github.com/hummingbird-project/hummingbird.git", exact: "2.5.0"),
    .package(url: "https://github.com/pointfreeco/swift-case-paths.git", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-url-routing.git", from: "0.6.2"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.6.2")
  ],
  targets: [
    .target(
      name: "EnvVars",
      dependencies: [
        .product(name: "Hummingbird", package: "hummingbird"),
        .product(name: "Dependencies", package: "swift-dependencies")
      ]
    ),
    .target(
      name: "PublicAssets",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
      ],
      resources: [.copy("assets")],
      plugins: [.plugin(name: "TypedAssetsPlugin", package: "swift-web")]
    ),    
    .target(
      name: "Models",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
      ]
    ),
    .target(
      name: "ActivityClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
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
        .product(name: "CasePaths", package: "swift-case-paths")
      ]
    ),
    .target(
      name: "Pages",
      dependencies: [
        "EnvVars",
        "Models",
        "ActivityClient",
        "PublicAssets",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "HTML", package: "swift-web"),
        .product(name: "Vue", package: "swift-web"),
        .product(name: "Hummingbird", package: "hummingbird")
      ]
    ),

    /// Executable
    .executableTarget(
      name: "App",
      dependencies: [
        "EnvVars",
        "Models",
        "Routes",
        "Pages",
        "ActivityClient",
        "PublicAssets",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "Hummingbird", package: "hummingbird"),
        .product(name: "HummingbirdRouter", package: "hummingbird"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "MiddlewareUtils", package: "swift-web")
      ]
    ),
  ],
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
        "-warn-long-expression-type-checking=250"
      ])
    ]
  }