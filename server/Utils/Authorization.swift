import CasePaths
import Dependencies
import Foundation
import Hummingbird
import Parsing

extension HTTPFields {
  func verifyAuthorization() throws {
    @Dependency(\.envVars) var env

    guard let basicAuthentication,
      basicAuthentication.0 == env.basicAuth.0,
      basicAuthentication.1 == env.basicAuth.1
    else {
      throw HTTPError(.notFound)
    }
  }
}

extension HTTPFields {
  public var authorization: Authorization? {
    if let string = self[.authorization] {
      try? Authorization.parser.parse(string)
    } else {
      nil
    }
  }

  public var basicAuthentication: (String, String)? {
    self.authorization?.basicAuthentication
  }

  @CasePathable
  public enum Authorization: Sendable, Equatable {
    case bearer(String)
    case basic(String, String)

    public var basicAuthentication: (String, String)? {
      guard case let .basic(username, password) = self else {
        return nil
      }
      return (username, password)
    }

    fileprivate static var parser: some ParserPrinter<Substring, Self> {
      OneOf {
        Parse(.case(\.bearer)) {
          "Bearer "
          Rest()
            .map(.string)
        }

        Parse(.case(\.basic)) {
          "Basic "

          Rest()
            .map(
              .convert {
                Data(base64Encoded: Data($0.utf8)).flatMap {
                  Substring(String(decoding: $0, as: UTF8.self))
                } ?? $0
              } unapply: {
                Substring(Data($0.utf8).base64EncodedString())
              }
            )
            .pipe {
              Prefix { $0 != ":" }
                .map(.string)
              ":"
              Rest()
                .map(.string)
            }
        }
      }
    }
  }
}
