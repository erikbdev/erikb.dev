import NIOCore
import TauTUI
import TinyStore

final class App: Container, @unchecked Sendable {
  let store: StoreOf<Feature> = Store(initialState: Feature.State()) {
    Feature()
  }

  convenience init() {
    self.init(children: [])

    let text = Text(text: "Hello, world!")
    self.addChild(text)

    store.observe { [weak self] in
      guard let self else { return }

      if self.store.isActive {
        text.text = "active!"
      } else {
        text.text = "not active"
      }

      self.invalidate()
    }
  }

  func handle(input: TerminalInput) {
    switch input {
    case .key(.character("a"), _):
      self.store.isActive.toggle()
    default:
      break
    }
  }

  struct Feature: Reducer {
    struct State {
      var choices = ["carrots", "celery"]
      var selected: Set<Int> = []
      var isActive = false
    }

    enum Action {
      case select
    }

    var body: some ReducerOf<Self> {
      Reduce { state, action in
        .none
      }
    }
  }
}
