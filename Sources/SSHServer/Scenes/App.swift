import NIOCore
import TauTUI
import TinyStore

final class App: AnyContainer {
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

  var children: [any Component] = []
  let store: StoreOf<Feature>

  init(store: StoreOf<Feature>) {
    self.store = store

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
    logger.debug("new event: \(input)")
    switch input {
    case .key(.character("a"), _):
      self.store.isActive.toggle()
    default:
      break
    }
  }
}
