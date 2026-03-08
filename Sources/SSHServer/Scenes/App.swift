import NIOCore
import TauTUI
import TinyStore

final class App: Component {
  let store: StoreOf<Feature>
  let title = Text(text: """
                     ███  █████      █████            █████                        
                    ░░░  ░░███      ░░███            ░░███                         
  ██████  ████████  ████  ░███ █████ ░███████      ███████   ██████  █████ █████   
 ███░░███░░███░░███░░███  ░███░░███  ░███░░███    ███░░███  ███░░███░░███ ░░███    
░███████  ░███ ░░░  ░███  ░██████░   ░███ ░███   ░███ ░███ ░███████  ░███  ░███    
░███░░░   ░███      ░███  ░███░░███  ░███ ░███   ░███ ░███ ░███░░░   ░░███ ███     
░░██████  █████     █████ ████ █████ ████████  ██░░████████░░██████   ░░█████      
 ░░░░░░  ░░░░░     ░░░░░ ░░░░ ░░░░░ ░░░░░░░░  ░░  ░░░░░░░░  ░░░░░░     ░░░░░       
"""
  )

  init(store: StoreOf<Feature>) {
    self.store = store
    super.init()
    self.addChild(title)
  }

  override func render(width: Int) -> [String] {
    super.render(width: width)
  }

  override func handle(input: TerminalInput) {
    switch input {
    case .key(.character("c"), modifiers: .control):
      Task { [store] in await store.send(.close) }
    default:
      break
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
