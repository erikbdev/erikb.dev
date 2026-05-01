#if canImport(Foundation)
  import Foundation
#endif

public struct Activity: Sendable, Equatable {
  public var location: Location?
  public var nowPlaying: NowPlaying?

  public init(location: Location? = nil, nowPlaying: NowPlaying? = nil) {
    self.location = location
    self.nowPlaying = nowPlaying
  }

  public var redacted: Activity {
    let redactedLocation = self.location.flatMap {
      Location(
        city: $0.city,
        state: $0.state,
        region: $0.region,
        // timestamp: $0.timestamp,
        residency: nil
      )
    }
    return Activity(
      location: redactedLocation,
      nowPlaying: self.nowPlaying
    )
  }
}

extension Activity {
  public struct Location: Sendable, Equatable {
    public let city: String?
    public let state: String?
    public let region: String?
    // public let timestamp: Date

    public let residency: Residency?

    public struct Residency: Sendable, Equatable, CustomStringConvertible {
      public let city: String
      public let state: String
      public var description: String { "\(city), \(state)" }

      public static let `default` = Residency(city: "Irvine", state: "CA")
    }
  }

  public struct NowPlaying: Sendable, Equatable {

    /// track title
    public let title: String

    /// artist name
    public let artist: String?

    /// album name
    public let album: String?

    /// time elapsed
    public let progress: Double

    /// total duration
    public let duration: Double

    /// timestamp of the request sent
    // public let timestamp: Date

    /// service used
    public let service: Service

    public enum Service: String, Sendable, Equatable {
      case appleMusic = "apple"
    }
  }
}

#if canImport(Foundation)
  extension Activity.Location: Codable {}
  extension Activity.Location.Residency: Codable {}
  extension Activity.NowPlaying.Service: Codable {}
  extension Activity.NowPlaying: Codable {}
  extension Activity: Codable {
    public static let encoder = {
      let encoder = JSONEncoder()
      encoder.dateEncodingStrategy = .iso8601
      return encoder
    }()

    public static let decoder = {
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      return decoder
    }()
  }
#endif
