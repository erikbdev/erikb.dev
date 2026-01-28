import Dependencies
import Foundation
import Testing

@testable import TinyComposableArchitecture

@Suite("Store Tests")
struct StoreTests {
  @Test func cancellableIsRemovedOnImmediatelyCompletingEffect() async {
    let store = Store<Void, Void>(initialState: ()) {}

    #expect(await store.effectCancellablesCount == 0)

    await store.send(())

    #expect(await store.effectCancellablesCount == 0)
  }

  @Test func cancellableIsRemovedWhenEffectCompletes() async {
    let clock = TestClock()
    enum Action { case start, end }

    let reducer = Reduce<Void, Action>({ _, action in
      switch action {
      case .start:
        return .run { store in
          @Dependency(\.continuousClock) var clock
          try await clock.sleep(for: .seconds(1))
        }
      case .end:
        return .none
      }
    })

    let store = Store(initialState: ()) {
      reducer
    } withDependencies: {
      $0.continuousClock = clock
    }

    #expect(await store.effectCancellablesCount == 0)

    let task = await store.send(.start)
    #expect(await store.effectCancellablesCount == 1)

    await clock.advance(by: .seconds(2))

    await task.finish()
    #expect(await store.effectCancellablesCount == 0)
  }
}

#if os(Linux)
  // https://github.com/swiftlang/swift/pull/77890
  // On Swift 6.2.1 on Linux, Observation runs into a linker error that swift::threading::fatal can't be found.
  // Seems to happen again when running test cases. So, stub it out.
  @_cdecl("_ZN5swift9threading5fatalEPKcz") func swift_threading_fatal() { fatalError("swift::threading::fatal") }
#endif
