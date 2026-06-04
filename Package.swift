// swift-tools-version:6.2

import PackageDescription

let package = Package(
  name: "portfolio",
  platforms: [
    .macOS(.v14)
  ],
  products: [
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

    .package(url: "https://github.com/hummingbird-project/hummingbird.git", exact: "2.5.0"),
    .package(url: "https://github.com/pointfreeco/swift-case-paths.git", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.0.0"),

    .package(url: "https://github.com/SwiftTUI/swift-tui.git", from: "0.0.14")
  ],
  targets: [
    /// SiteServer
    .executableTarget(
      name: "SiteServer",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        .product(name: "Hummingbird", package: "hummingbird"),
        .product(name: "HummingbirdRouter", package: "hummingbird"),
        .product(name: "HummingbirdURLRouting", package: "swift-web"),
        .product(name: "MiddlewareUtils", package: "swift-web"),
        .product(name: "CasePaths", package: "swift-case-paths"),
      ],
      path: "server"
    ),
    // SSH Server
    .executableTarget(
      name: "SiteSSHServer",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        .product(name: "NIO", package: "swift-nio"),
        .product(name: "NIOConcurrencyHelpers", package: "swift-nio"),
        .product(name: "NIOSSH", package: "swift-nio-ssh"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "SwiftTUI", package: "swift-tui", moduleAliases: ["UnixSignals": "SwiftTUIUnixSignals"]),
        .product(name: "SwiftTUITerminal", package: "swift-tui", moduleAliases: ["UnixSignals": "SwiftTUIUnixSignals"])
      ],
      path: "ssh-server"
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
