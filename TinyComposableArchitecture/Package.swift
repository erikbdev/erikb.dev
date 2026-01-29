// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "tiny-composable-architecture",
  products: [
    .library(
      name: "TinyComposableArchitecture",
      targets: ["TinyComposableArchitecture"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.6.0"),
    .package(url: "https://github.com/pointfreeco/swift-case-paths.git", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-perception.git", from: "2.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.0.0"),
    .package(url: "https://github.com/erikbdev/swift-navigation.git", revision: "54fdf6ee21fd4607634c2aa0449daa2ff49cb20b")
  ],
  targets: [
    .target(
      name: "TinyComposableArchitecture",
      dependencies: [
        .product(name: "Perception", package: "swift-perception"),
        .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "CasePaths", package: "swift-case-paths"),
        .product(name: "SwiftNavigation", package: "swift-navigation")
      ]
    ),

    .testTarget(
      name: "TinyComposableArchitectureTests",
      dependencies: ["TinyComposableArchitecture"]
    ),
  ]
)
