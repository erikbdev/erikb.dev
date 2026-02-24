import NIOCore
import TauTUI
import TinyStore

final class App: AnyContainer {
  struct Feature: Reducer {
    struct State {
      var choices = ["carrots", "celery"]
      var selected: Set<Int> = []
      var isActive = false
      var input = ""
    }

    enum Action {
      case input(_ input: TerminalInput)
    }

    var body: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .input(.key(.enter, _)):
          state.isActive = false
        case .input(.key(.character(let c), _)) where state.isActive:
          state.input.append(c)
        case .input:
          break
        }
        return .none
      }
    }
  }

  var children: [any Component] = []
  let store: StoreOf<Feature>
  let text = Text(text: "Hello, world!")
  let input = Input(value: "(empty)")

  init(store: StoreOf<Feature>) {
    self.store = store
    self.addChild(text)
    self.addChild(input)

    store.observe { [weak self] in
      // guard let self else { return }

      // self.invalidate()
    }
  }

  func handle(input: TerminalInput) {
    switch input {
    case .key(.enter, _):
      self.store.isActive.toggle()
    default:
      self.input.handle(input: input)
    }
  }
}
