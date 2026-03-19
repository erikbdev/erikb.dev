import Dependencies 

extension ActivityClient: DependencyKey {
  public static let liveValue: ActivityClient = {
    let state = LockIsolated((Location?.none, NowPlaying?.none))
    return ActivityClient(
      location: { state.withValue { $0.0 } },
      updateLocation: { newLocation in
        state.withValue { $0.0 = newLocation }
      },
      nowPlaying: { state.withValue { $0.1 } },
      updateNowPlaying: { nowPlaying in
        state.withValue { $0.1 = nowPlaying }
      }
    )
  }()
}
