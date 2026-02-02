import NIOCore
import TinyComposableArchitecture

struct App: Component {
  let store: StoreOf<Feature>

  var body: some Component {
    if !store.state.isActive {
      Text("Hello!")
    } else {
      Text("What kind of food would you like to order?")
    }
    // .padding(.bottom, 1)

    // for i in choices {
    //   Text("\()")
    // }

    // Text("(press q to quit)")
    //   .padding(.bottom, 1)
  }

  struct Feature: Reducer {
    struct State {
      var cursor = 0
      var choices = ["carrots", "celery"]
      var selected: Set<Int> = []
      var isActive = false
      var size = Size.zero
    }

    enum Action {
      case event(TerminalEvent)
    }

    var body: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case let .event(.key(event)) where event.character == "a":
          state.isActive.toggle()
          return .none
        default:
          return .none
        }
      }
    }
  }
}
