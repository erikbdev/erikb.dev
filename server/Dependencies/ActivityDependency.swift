import Dependencies
import DependenciesMacros
import Models

@DependencyClient
public struct ActivityClient: Sendable {
  private(set) var activity: @Sendable () -> Activity?
  private(set) var updateLocation: @Sendable (Activity.Location?) -> Void
  private(set) var updateNowPlaying: @Sendable (Activity.NowPlaying?) -> Void
}

extension ActivityClient {
  static var live: Self {
    let storage = LockIsolated(Activity())
    return Self(
      activity: { storage.value }, 
      updateLocation: { newValue in storage.withValue { $0.location = newValue } },
      updateNowPlaying: { newValue in storage.withValue { $0.nowPlaying = newValue } }
    )
  }
}

extension Activity: DependencyKey {
  public static let liveValue = ActivityClient.live
}

extension DependencyValues {
  public var activity: ActivityClient {
    get { self[Activity.self] }
    set { self[Activity.self] = newValue }
  }
}