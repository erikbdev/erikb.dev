import SwiftTUI

struct HomeView: View {
  @Environment(\.terminalSize) private var terminalSize

  var body: some View {
    ScrollView {
      HStack(alignment: .top, spacing: 2) {
        SpinnerView()

        VStack(alignment: .leading, spacing: 0) {
          row(label: "name", value: "Erik Bautista Santibanez")
          row(label: "role", value: "Mobile & Web Developer")
          row(label: "location", value: "Irvine, CA")
          row(label: "tech", value: "Swift, Rust, Typescript")
          row(label: "email", value: "me@erikb.dev")
          row(label: "github", value: "github.com/erikbdev")
          row(label: "linkedin", value: "linkedin.com/erikbautista")
          row(label: "resume", value: "https://erikb.dev/resume.pdf")

          Text(
            """
            Software developer who builds applications using Swift and modern web technologies.
            Currently working on `\(Text("$ ssh erikb.dev").foregroundStyle(.yellow).bold())`.
            """
          )
          .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  private func row(label: String, value: String) -> some View {
    HStack(spacing: 0) {
      Text("\(label): ")
        .foregroundStyle(.gray)
      Text(value)
    }
  }
}
