import Parsing
import CasePaths
import Dependencies
import Hummingbird
import Foundation

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
    /// Token
    case bearer(String)

    /// base64-encoded credentials
    case basic(String, String)

    public var basicAuthentication: (String, String)? {
      guard case let .basic(username, password) = self else {
        return nil
      }
      return (username, password)
    }

    fileprivate static var parser: some Parser<Substring, Self> {
      OneOf {
        Parse(.case(\.bearer)) {
          OneOf {
            "Bearer"
            "bearer"
          }
          " "
          Rest().map(.string)
        }

        Parse(.case(\.basic)) {
          OneOf {
            "Basic"
            "basic"
          }
          " "

          Rest().map(Base64EncodedSubstringToSubstring()).pipe {
            Prefix { $0 != ":" }.map(.string)
            ":"
            Rest().map(.string)
          }
        }

        Parse(.case(\.digest)) {
          OneOf {
            "Digest"
            "digest"
          }
          " "
          Rest().map(.string)
        }
      }
    }
  }
}

private struct Base64EncodedSubstringToSubstring: Conversion {
  @usableFromInline
  init() {}

  @inlinable
  func apply(_ input: Substring) -> Substring {
    Data(base64Encoded: String(input)).flatMap {
      String(decoding: $0, as: UTF8.self)[...]
    } ?? ""
  }

  @inlinable
  func unapply(_ output: Substring) -> Substring {
    output.data(using: .utf8)?
      .base64EncodedString()[...] ?? ""
  }
}