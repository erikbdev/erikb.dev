import NIOCore
import TinyComposableArchitecture

struct App: Cell {
  let store: StoreOf<Feature>

  var body: some Cell {
    Text("What kind of food would you like to order?")
      .padding(.bottom, 1)

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
    }

    enum Action {
      case event(Event)
    }

    var body: some ReducerOf<Self> {
      Reduce { state, action in
        .none
      }
    }
  }
}

extension App.Feature.Action {
  enum Event {
    case key(KeyEvent)
    // case mouse
    case resize(Size)
    case exit

    struct KeyEvent {
      let character: Character?
      let keycode: UInt16
      // let modifiers: Modifiers
      let isPress: Bool
    }

    struct Size {
      let width: Int
      let height: Int
      let rowHeight: Int
      let charWidth: Int
    }
  }

}
