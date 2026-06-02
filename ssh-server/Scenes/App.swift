// SwiftTUITerminal re-exports SwiftTUIRuntime (App, WindowGroup, Scene)
// and SwiftTUIViews (View, Text, VStack, …) without pulling in the
// argument-parser-backed SwiftTUI.App overlay.
import SwiftTUITerminal

@MainActor
struct PortfolioApp: App {
  nonisolated init() {}

  var body: some Scene {
    WindowGroup {
      DemoView()
    }
    .exitOnKey(.character("q"))
  }
}

// MARK: - Root

enum DemoTab: String, Hashable, Sendable, CaseIterable {
  case counter, input, scroll, settings
}

struct DemoView: View {
  @State private var tab: DemoTab = .counter

  var body: some View {
    TabView(selection: $tab) {
      Tab("Counter", value: DemoTab.counter) { CounterTab() }
      Tab("Input",   value: DemoTab.input)   { InputTab() }
      Tab("Scroll",  value: DemoTab.scroll)  { ScrollTab() }
      Tab("Settings",value: DemoTab.settings){ SettingsTab() }
    }
  }
}

// MARK: - Counter tab
// Tests: Button action, @State mutation, conditional rendering

struct CounterTab: View {
  @State private var count = 0

  private var statusText: String {
    if count > 0 { return "positive" }
    if count < 0 { return "negative" }
    return "zero"
  }

  var body: some View {
    VStack(alignment: .center, spacing: 1) {
      Text("Count: \(count)")
        .bold()
      Text("(\(statusText))")
        .foregroundStyle(count > 0 ? Color.green : count < 0 ? Color.red : Color.gray)
      HStack(spacing: 2) {
        Button("  -  ") { count -= 1 }
        Button("  +  ") { count += 1 }
        Button("Reset") { count = 0 }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

// MARK: - Input tab
// Tests: TextField typing, @FocusState navigation, button submit, list display

struct InputTab: View {
  enum Field: Hashable { case name, message }

  @State private var name = ""
  @State private var message = ""
  @State private var entries: [(name: String, message: String)] = []
  @FocusState private var focused: Field?

  var body: some View {
    VStack(spacing: 1) {
      HStack {
        Text("Name:   ")
        TextField("enter name", text: $name)
          .focused($focused, equals: .name)
      }
      HStack {
        Text("Message:")
        TextField("enter message", text: $message)
          .focused($focused, equals: .message)
      }
      HStack(spacing: 2) {
        Button("Submit") {
          guard !name.isEmpty else { return }
          entries.append((name: name, message: message))
          name = ""
          message = ""
          focused = .name
        }
        Button("Clear") {
          entries = []
        }
      }
      Divider()
      if entries.isEmpty {
        Text("No entries yet — submit one above.")
          .foregroundStyle(.gray)
      } else {
        ScrollView {
          ForEach(Array(entries.enumerated()), id: \.offset) { i, entry in
            HStack {
              Text("\(i + 1). \(entry.name)")
                .bold()
              Text(entry.message)
                .foregroundStyle(.gray)
            }
          }
        }
      }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

// MARK: - Scroll tab
// Tests: ScrollView, ForEach, tap-to-select state

struct ScrollTab: View {
  @State private var selected: Int? = nil

  var body: some View {
    VStack(spacing: 1) {
      if let s = selected {
        Text("Selected: Item \(s)")
          .bold()
          .foregroundStyle(.green)
      } else {
        Text("Tap an item to select it")
          .foregroundStyle(.gray)
      }
      Divider()
      ScrollView {
        VStack {
          ForEach(1...40, id: \.self) { i in
            Button(selected == i ? "> Item \(i) <" : "  Item \(i)  ") {
              selected = selected == i ? nil : i
            }
          }
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

// MARK: - Settings tab
// Tests: Toggle, reactive computed state

struct SettingsTab: View {
  @State private var notifications = true
  @State private var darkMode = false
  @State private var autoSave = true
  @State private var animations = true

  private var enabledCount: Int {
    [notifications, darkMode, autoSave, animations].filter { $0 }.count
  }

  var body: some View {
    VStack(spacing: 1) {
      Text("\(enabledCount) of 4 settings enabled")
        .bold()
      Divider()
      Toggle("Notifications", isOn: $notifications)
      Toggle("Dark Mode",     isOn: $darkMode)
      Toggle("Auto Save",     isOn: $autoSave)
      Toggle("Animations",    isOn: $animations)
      Divider()
      Text(enabledCount == 4 ? "All on" : enabledCount == 0 ? "All off" : "Mixed")
        .foregroundStyle(enabledCount == 4 ? Color.green : enabledCount == 0 ? Color.red : Color.yellow)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
