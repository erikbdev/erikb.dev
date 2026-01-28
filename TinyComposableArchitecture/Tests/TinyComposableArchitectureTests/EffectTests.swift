import Dependencies
import Foundation
import Testing

@testable import TinyComposableArchitecture

@Suite("Effect tests")
struct EffectTests {
  @Test
  func testRun() async {
    struct State: Equatable {
      var responded = false
    }
    enum Action: Equatable { case tapped, response }
    let store = Store(initialState: State()) {
      Reduce<State, Action> { state, action in
        switch action {
        case .tapped:
          return .run { $0.send(.response) }
        case .response:
          state.responded = true
          return .none
        }
      }
    }
    await store.send(.tapped).finish()
    #expect(await store.state.responded)
  }

  @Test
  func testRunCatch() async {
    struct State: Equatable {
      var responded = true
    }
    enum Action: Equatable { case tapped, response }
    let store = Store(initialState: State()) {
      Reduce<State, Action> { state, action in
        switch action {
        case .tapped:
          return .run { _ in
            struct Failure: Error {}
            throw Failure()
          } catch: { _, store in
            store.send(.response)
          }
        case .response:
          state.responded = true
          return .none
        }
      }
    }
    await store.send(.tapped).finish() 
    #expect(await store.state.responded)
  }

  @Test
  func testRunCancellation() async {
    enum CancelID { case response }
    struct State: Equatable {}
    enum Action: Equatable { case tapped, response }
    let store = Store(initialState: State()) {
      Reduce<State, Action> { state, action in
        switch action {
        case .tapped:
          return .run { store in
            // Task.cancel(id: CancelID.response)
            try Task.checkCancellation()
            store.send(.response)
          }
          // .cancellable(id: CancelID.response)
        case .response:
          return .none
        }
      }
    }
    await store.send(.tapped).finish()
  }

  @Test
  func testRunCancellationCatch() async {
    enum CancelID { case responseA }
    struct State: Equatable {}
    enum Action: Equatable { case tapped, responseA, responseB }
    let store = Store(initialState: State()) {
      Reduce<State, Action> { state, action in
        switch action {
        case .tapped:
          return .run { store in
            // Task.cancel(id: CancelID.responseA)
            try Task.checkCancellation()
            store.send(.responseA)
          } catch: { _, store in
            store.send(.responseB)
          }
        // .cancellable(id: CancelID.responseA)
        case .responseA, .responseB:
          return .none
        }
      }
    }
    await store.send(.tapped).finish()
  }
}
