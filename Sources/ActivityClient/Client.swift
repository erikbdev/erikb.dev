import ClientDependency

#if canImport(Foundation)
  import Foundation
#endif

public struct ActivityClient: Sendable {
  public var location: @Sendable () -> Location? = { nil }
  public var updateLocation: @Sendable (_ location: Location?) -> Void = { _ in }
  public var nowPlaying: @Sendable () -> NowPlaying? = { nil }
  public var updateNowPlaying: @Sendable (_ nowPlaying: NowPlaying?) -> Void = { _ in }
}

extension ActivityClient {
  public func redactedActivity() -> Activity {
    let location = self.location()
    let redactedLocation = location.flatMap {
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
      nowPlaying: self.nowPlaying()
    )
  }

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

      public static let `default` = Residency(city: "Redacted", state: "Redacted")
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
      case apple
    }
  }

  public struct Activity: Sendable, Equatable {
    public let location: Location?
    public let nowPlaying: NowPlaying?
  }
}

#if canImport(Foundation)
  extension ActivityClient.Location: Codable {}
  extension ActivityClient.Location.Residency: Codable {}
  extension ActivityClient.NowPlaying.Service: Codable {}
  extension ActivityClient.NowPlaying: Codable {}
  extension ActivityClient.Activity: Codable {
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

extension ClientValues {
  @Entry public var activityClient = ActivityClient.defaultClient
}