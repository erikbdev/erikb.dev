import Foundation
import Dependencies
import DependenciesMacros

@DependencyClient
public struct ActivityClient: Sendable {
  public private(set) var activity: @Sendable () -> Activity?
  public private(set) var updateLocation: @Sendable (Activity.Location?) -> Void
  public private(set) var updateNowPlaying: @Sendable (Activity.NowPlaying?) -> Void
}

extension ActivityClient {
  public static var live: Self {
    let storage = LockIsolated(Activity())
    return Self(
      activity: { storage.value },
      updateLocation: { newValue in storage.withValue { $0.location = newValue } },
      updateNowPlaying: { newValue in storage.withValue { $0.nowPlaying = newValue } }
    )
  }
}

extension ActivityClient: DependencyKey {
  public static let liveValue = ActivityClient.live
}

extension DependencyValues {
  public var activity: ActivityClient {
    get { self[ActivityClient.self] }
    set { self[ActivityClient.self] = newValue }
  }
}

public struct Activity: Sendable, Equatable, Codable {
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
        residency: $0.residency
      )
    }
    return Activity(
      location: redactedLocation,
      nowPlaying: self.nowPlaying
    )
  }

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

extension Activity {
  public struct Location: Sendable, Equatable, Codable {
    public let city: String?
    public let state: String?
    public let region: String?
    // public let timestamp: Date

    public let residency: Residency?

    public struct Residency: Sendable, Equatable, CustomStringConvertible, Codable {
      public let city: String
      public let state: String
      public var description: String { "\(city), \(state)" }

      public static let `default` = Residency(city: "Irvine", state: "CA")
    }
  }

  public struct NowPlaying: Sendable, Equatable, Codable {

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
    public let timestamp: Date

    /// service used
    public let service: Service

    public enum Service: String, Sendable, Equatable, Codable {
      case appleMusic = "apple"
    }
  }
}