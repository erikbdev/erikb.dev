struct HomeScreen: Component {
  var choices = ["carrots", "celery"]
  var selected: Set<Int> = []
  var cursor = 0

  var body: some Component {
    Text("What kind of food would you like to order?")
      .padding(.bottom, 1)

    // for i in choices {
    //   Text("\()")
    // }

    // Text("(press q to quit)")
    //   .padding(.bottom, 1)
  }

  func renderBody() {

  }

  mutating func update(_ event: ()) {

  }
}
