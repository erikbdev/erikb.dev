import Foundation
import Testing
import TinyComposableArchitecture

@Suite("Store Tests")
struct StoreTests {
  @Test func testStoreAction() async throws {
    let store = Store(initialState: TestStoreActions.State()) {
      TestStoreActions()
    }

    print("Test started at \(Date.now)")
    await store.send(.increment).finish()
    print("Test Finished at \(Date.now)")
    #expect(store.withState(\.count) == 10)
  }

  struct TestStoreActions: Reducer {
    struct State: Equatable {
      var count = 0
    }

    enum Action {
      case increment
      case set(Int)
    }

    var body: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .increment:
          // state.count += 1
          return .run { send in
            print("Send started at \(Date.now)")
            try await Task.sleep(for: .seconds(10))
            await send(.set(10)).finish()
            print("Send Finished at \(Date.now)")
          }
        case .set(let count):
          state.count = count
        }
        return .none
      }
    }
  }
}

#if os(Linux)
  // https://github.com/swiftlang/swift/pull/77890
  // On Swift 6.2.1 on Linux, Observation runs into a linker error that swift::threading::fatal can't be found.
  // Seems to happen again when running test cases. So, stub it out.
  @_cdecl("_ZN5swift9threading5fatalEPKcz") func swift_threading_fatal() { fatalError("swift::threading::fatal") }
#endif
