import Foundation
import Testing
@testable import TinyComposableArchitecture

@Suite("Store Tests")
struct StoreTests {
  @Test func testStoreAction() async throws {
    let store = Store(initialState: TestStoreReducer.State()) {
      TestStoreReducer()
    }

    let task = await store.send(.increment)
    #expect(await store.count == 1)
    task.cancel()
    try await Task.sleep(for: .seconds(15))
    #expect(await store.count == 1)
    await store.send(.increment).finish()
    #expect(await store.count == 10)
  }

  @Test func testParallelActor() async throws {
    let store = Store(initialState: TestStoreReducer.State()) {
      TestStoreReducer()
    }

    try await withThrowingTaskGroup { group in
      group.addTask {
        await store.send(.startCountLoop).finish()
      }
      group.addTask {
        await store.send(.startStringLoop).finish()
      }
      group.addTask {
        try await Task.sleep(for: .seconds(5))
        #expect(await store.effectCount() == 2)
        try await Task.sleep(for: .seconds(12))
        #expect(await store.effectCount() == 0)
      }
      try await group.waitForAll()
    }
  }

  struct TestStoreReducer: Reducer {
    struct State: Equatable {
      var count = 0
      var string = ""
    }

    enum Action {
      case increment
      case set(Int)
      case startCountLoop
      case startStringLoop
    }

    var body: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .increment:
          state.count += 1
          return .run { store in
            try await Task.sleep(for: .seconds(10))
            store.send(.set(10))
          }
        case .set(let count):
          state.count = count
        case .startCountLoop:
          return .run { store in
            for _ in 0..<10 {
              store.modify { $0.count += 1 }
              print("incrementing count: \(store.count)")
              try await Task.sleep(for: .seconds(1))
            }
          }
         case .startStringLoop:
          return .run { store in
            for _ in 0..<10 {
              store.modify { $0.string += "A" }
              print("incrementing string: \(store.string)")
              try await Task.sleep(for: .seconds(1))
            }
          }
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
