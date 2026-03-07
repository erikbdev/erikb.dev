import NIOCore
import TauTUI
import TinyStore

final class App: AnyContainer {
  var children: [any Component] = []
  let store: StoreOf<Feature>
  let text = Text(text: "Hello, world!")
  let input = Input(value: "")

  init(store: StoreOf<Feature>) {
    self.store = store
    self.addChild(text)
    self.addChild(input)

    store.observe { [weak self] in
      guard let self else { return }
      if self.store.isActive {
        text.background = .init(red: 255, green: 0, blue: 0)
      } else {
        text.background = nil
      }
      text.text = self.store.isActive ? "Active" : "Inactive"
      self.invalidate()
    }
  }

  func handle(input: TerminalInput) {
    switch input {
    case .key(.enter, _):
      self.store.isActive.toggle()
    case .key(.character("c"), modifiers: .control):
      Task { [store] in await store.send(.close) }
    default:
      if self.store.isActive {
        self.input.handle(input: input)
      }
    }
  }
}

extension App {
  struct Feature: Reducer {
    struct State {
      var choices = ["carrots", "celery"]
      var selected: Set<Int> = []
      var isActive = false
      var input = ""
    }

    enum Action {
      case close
    }

    @Dependency(\.exitApp) var closeApp

    var body: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .close:
          closeApp()
        }
        return .none
      }
    }
  }
}
