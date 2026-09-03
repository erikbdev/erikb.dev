import Elementary
import Shared

struct ActivityFragment: HTML {
  var activity: Activity?

  var body: some HTML {
    if let location = activity?.location, location.city != nil || location.state != nil || location.region != nil {
      p {
        "Currently in "
        span(.class("activity-location")) {
          [location.city, location.state, location.region]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
        }
      }
    }
    if let nowPlaying = activity?.nowPlaying {
      p {
        "Listening to "
        span(.class("activity-track")) {
          [nowPlaying.title, nowPlaying.artist].compactMap { $0 }.joined(separator: " — ")
        }
      }
    }
  }
}
