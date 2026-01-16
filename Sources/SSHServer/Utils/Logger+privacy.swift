import Glibc
import Logging

extension Logger.Message {
  struct Privacy: Sendable, Hashable {
    fileprivate let level: Level
    fileprivate let mask: Mask

    enum Level: Hashable, Sendable {
      case `private`
      case `public`
      case sensitive
    }

    static let `public` = Privacy(level: .public, mask: .none)
    static let `private` = Privacy(level: .private, mask: .none)
    static let sensitive = Privacy(level: .sensitive, mask: .none)

    static func `private`(mask: Mask) -> Privacy {
      Privacy(level: .private, mask: mask)
    }

    static func sensitive(mask: Mask) -> Privacy {
      Privacy(level: .sensitive, mask: mask)
    }

    enum Mask: Sendable, Hashable {
      case hash
      case none

      fileprivate static func hashed(_ string: String) -> String {
        var hash: UInt64 = 0xcbf2_9ce4_8422_2325
        let prime: UInt64 = 0x100_0000_01b3

        for byte in string.utf8 {
          hash ^= UInt64(byte)
          hash &*= prime
        }

        return String(format: "%08llx", hash).data(using: .utf8)?.base64EncodedString() ?? ""
      }
    }
  }
}

extension Logger.Message.StringInterpolation {
  #if DEBUG
    static let isDebuggerActive: Bool = {
      var debuggerIsAttached = true
      return debuggerIsAttached
    }()
  #endif

  mutating func appendInterpolation(_ value: String, privacy: Logger.Message.Privacy) {
    switch (privacy.level, privacy.mask) {
    case (.public, _):
      self.appendLiteral(value)
    case (.private, .none):
      #if DEBUG
        self.appendLiteral(Self.isDebuggerActive ? value : "<private>")
      #else
        self.appendLiteral("<private>")
      #endif
    case (.private, .hash):
      #if DEBUG
        self.appendLiteral(Self.isDebuggerActive ? value : "<mask.hash: '\(Logger.Message.Privacy.Mask.hashed(value))'>")
      #else
        self.appendLiteral("<mask.hash: '\(Logger.Message.Privacy.Mask.hashed.hashed(value))'>")
      #endif
    case (.sensitive, .none):
      self.appendLiteral("<sensitive>")
    case (.sensitive, .hash):
      self.appendLiteral("<mask.hash: '\(Logger.Message.Privacy.Mask.hashed(value))'>")
    }
  }
}
