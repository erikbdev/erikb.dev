import NIOCore
import TinyStore
import TauTUI

struct App {
  let store: StoreOf<Feature> = Store(initialState: Feature.State()) {
    Feature()
  }

  struct Feature: Reducer {
    struct State {
      var choices = ["carrots", "celery"]
      var selected: Set<Int> = []
      var isActive = false
    }

    enum Action {
    }

    var body: some ReducerOf<Self> {
      Reduce { state, action in
          return .none
      }
    }
  }
}
