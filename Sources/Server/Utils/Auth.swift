import Dependencies
import EnvVars
import Foundation
import Hummingbird
import HummingbirdURLRouting
import Parsing

extension HTTPFields.Authorization {
  func validate() throws {
    @Dependency(\.envVars) var env
    switch self {
    case let .basic(username, pass):
      if username != env.basicAuth.0 || pass != env.basicAuth.1 {
        throw HTTPError(.notFound)
      }
    default: throw HTTPError(.notFound)
    }
  }
}
