import Dependencies
import DependenciesMacros

extension ActivityClient: DependencyKey {
  public static var liveValue: ActivityClient {
    let state = LockIsolated((Location?.none, NowPlaying?.none))
    return ActivityClient(
      location: { state.value.0 },
      updateLocation: { newLocation in
        state.withValue { $0.0 = newLocation }
      },
      nowPlaying: { state.value.1 },
      updateNowPlaying: { nowPlaying in
        state.withValue { $0.1 = nowPlaying }
      }
    )
  }
}
