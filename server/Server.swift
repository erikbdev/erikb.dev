import ArgumentParser
import Dependencies
import Hummingbird
import HummingbirdRouter
import Logging

private let logger = Logger(label: "portfolio-server")

@main
struct Server: AsyncParsableCommand {
  @Option(name: .shortAndLong)
  var hostname = "127.0.0.1"

  @Option(name: .shortAndLong)
  var port = 8080

  func run() async throws {
    try await withDependencies { deps in
      #if DEBUG
        deps.envVars = try await .dotEnv()
      #endif
    } operation: {
      let app = self.buildApp()
      #if DEBUG
        let buildMode = "development"
      #else
        let buildMode = "release"
      #endif
      logger.info("Running server in '\(buildMode)' mode")
      try await app.runService()
    }
  }

  func buildApp() -> some ApplicationProtocol {
    let router = Router()
    router.addMiddleware {
      SiteMiddleware()
    }

    return Application(
      router: router,
      configuration: ApplicationConfiguration(
        address: .hostname(self.hostname, port: self.port),
        serverName: "erikb.dev"
      ),
      logger: logger
    )
  }
}
