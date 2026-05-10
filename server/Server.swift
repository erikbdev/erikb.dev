import ArgumentParser
import Dependencies
import Hummingbird
import HummingbirdRouter
import Logging

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
      app.logger.info("Running server in '\(buildMode)' mode")
      try await app.runService()
    }
  }

  func buildApp() -> some ApplicationProtocol {
    @Dependency(\.envVars) var envVars

    let router = Router()
    var logger = Logger(label: "portfolio-server")

    if let logLevel = envVars.get("LOG_LEVEL", as: Logger.Level.self) {
      logger.logLevel = logLevel
    } else {
      #if DEBUG
        logger.logLevel = .debug
      #endif
    }

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
