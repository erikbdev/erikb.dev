func withFrameClock(
  fps: UInt = 60,
  operation: @escaping @Sendable (_ timestamp: ContinuousClock.Instant) async throws -> Void,
  tasks: @escaping @Sendable (inout ThrowingDiscardingTaskGroup<Error>) -> Void,
) async throws {
  try await withThrowingDiscardingTaskGroup { group in
    group.addTask {
      let duration = Duration.seconds(1.0 / Double(fps))
      var lastTimestamp = ContinuousClock.now
      repeat {
        let targetTimestamp = lastTimestamp + duration
        let now = ContinuousClock.now

        if targetTimestamp > now {
          try await Task.sleep(for: targetTimestamp - now)
        }

        lastTimestamp = targetTimestamp

        try await operation(targetTimestamp)

      } while !Task.isCancelled
    }
    tasks(&group)
  }
}
