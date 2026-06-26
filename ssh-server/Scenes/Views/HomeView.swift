import SwiftTUI

struct HomeView: View {
  @State private var cursorVisible = true

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 0) {
        heroSection
        Divider()
        bioSection.padding()
        Divider()
        linksSection.padding()
      }
    }
    .task {
      do {
        while true {
          try await Task.sleep(for: .milliseconds(530))
          cursorVisible.toggle()
        }
      } catch {}
    }
  }

  // MARK: - Hero

  private var heroSection: some View {
    HStack(alignment: .top, spacing: 2) {
      VStack(alignment: .leading, spacing: 1) {
        Text(nameBanner)
          .foregroundStyle(.green)
        profileInfo
      }
      .frame(maxWidth: .infinity)
      SpinnerView()
    }
    .padding()
  }

  // Small figlet-style banner for "ERIKB"
  // Row widths: E=5, R=5, I=5, K=6, B=5, each separated by 1 space → 30 chars wide
  private let nameBanner = """
   ___   ___    ___   _  __  ___
  | __| | _ \\ |_ _| | |/ / | _ )
  | _|  |   /  | | |   <  | _ \\
  |___| |_|_\\ |___| |_|\\_\\ |___/
  """

  private var profileInfo: some View {
    VStack(alignment: .leading, spacing: 0) {
      Divider()
      row(label: "name", value: "Erik Bautista Santibanez")
      row(label: "role", value: "Mobile & Web Developer")
      row(label: "from", value: "Irvine, CA")
      row(label: "tech", value: "Swift · TypeScript")
    }
  }

  private func row(label: String, value: String) -> some View {
    HStack(spacing: 0) {
      Text("  \(label)  ").foregroundStyle(.gray)
      Text(value)
    }
  }

  // MARK: - Bio

  private var bioSection: some View {
    Text(
      "I'm a passionate software developer who builds applications using Swift and modern web technologies."
    )
    .foregroundStyle(.gray)
  }

  // MARK: - Links

  private var linksSection: some View {
    VStack(alignment: .leading, spacing: 1) {
      Link("[/email](me@erikb.dev)", destination: "mailto:me@erikb.dev")
      Link("[/resume.pdf](/ebs-resume.pdf)", destination: "https://erikb.dev/ebs-resume.pdf")
      Link("[/github](/erikbdev)", destination: "https://github.com/erikbdev")
      Link("[/linkedin](/erikbautista)", destination: "https://linkedin.com/in/erikbautista")
    }
  }
}
