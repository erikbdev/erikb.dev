import Dependencies
import Shared

struct ActivityComponent: HTML {
  @Dependency(\.activityClient.activity) private var activity

  var body: some HTML {
    /* html */
    """
    <p>\(MapPinIcon())\((activity().location?.residency ?? .default).description)</p>
    """

    if let location = activity().location,
      location.city != nil || location.state != nil || location.region != nil,
      location.residency?.city != location.city || location.state != location.state
    {
      /* html */
      """
      <p>\(LocationPinIcon())Currently in <span class="activity-location">\([location.city, location.state, location.region].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ", "))</span></p>
      """
    }
    if let nowPlaying = activity().nowPlaying {
      /* html */
      """
      <p>\(MusicNotesIcon())Listening to <span class="activity-track">\([nowPlaying.title, nowPlaying.artist].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " — "))</span></p>
      """
    }
  }
}

private struct MapPinIcon: HTML {
  var body: some HTML {
    /* html */
    """
    <svg class="activity-icon" viewBox="0 0 256 256">
      <path d="M128,16a88.1,88.1,0,0,0-88,88c0,75.3,80,132.17,83.41,134.55a8,8,0,0,0,9.18,0C136,236.17,216,179.3,216,104A88.1,88.1,0,0,0,128,16Zm0,56a32,32,0,1,1-32,32A32,32,0,0,1,128,72Z"></path>
    </svg>
    """
  }
}

private struct LocationPinIcon: HTML {
  var body: some HTML {
    /* html */
    """
    <svg class="activity-icon" viewBox="0 0 256 256">
      <path d="M248,121.58a15.76,15.76,0,0,1-11.29,15l-.2.06-78,21.84-21.84,78-.06.2a15.77,15.77,0,0,1-15,11.29h-.3a15.77,15.77,0,0,1-15.07-10.67L41,61.41a1,1,0,0,1-.05-.16A16,16,0,0,1,61.25,40.9l.16.05,175.92,65.26A15.78,15.78,0,0,1,248,121.58Z"></path>
    </svg>
    """
  }
}

private struct MusicNotesIcon: HTML {
  var body: some HTML {
    /* html */
    """
    <svg class="activity-icon" viewBox="0 0 256 256">
      <path d="M212.92,17.71a7.89,7.89,0,0,0-6.86-1.46l-128,32A8,8,0,0,0,72,56V166.1A36,36,0,1,0,88,196V102.25l112-28V134.1A36,36,0,1,0,216,164V24A8,8,0,0,0,212.92,17.71Z"></path>
    </svg>
    """
  }
}
