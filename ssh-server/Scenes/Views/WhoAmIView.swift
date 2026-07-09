import SwiftTUI

struct HomeView: View {
  @Environment(\.terminalSize) private var terminalSize

  var body: some View {
    Group {
      Text("\(Text("$").foregroundStyle(.yellow)) whoami")
      ScrollView(.vertical) {
        VStack(alignment: .leading, spacing: 0) {
          HStack(alignment: .top, spacing: 2) {
            SpinnerView()
              .layoutPriority(1)

            VStack(alignment: .leading, spacing: 0) {
              Text("erikb@dev")
                .safeAreaInset(edge: .bottom) {
                  Divider(strokeStyle: .ascii)
                }
              row(label: "name", value: "Erik Bautista Santibanez")
              row(label: "role", value: "Mobile & Web Developer")
              row(label: "location", value: "Irvine, CA")
              row(label: "tech stack", value: "Swift, Typescript, Rust")
              row(label: "email", value: "me@erikb.dev", url: "mailto:me@erikb.dev")
              row(label: "github", value: "github.com/erikbdev", url: "https://github.com/erikbdev")
              row(label: "linkedin", value: "linkedin.com/in/erikbautista", url: "https://linkedin.com/in/erikbautista")
              row(label: "resume", value: "erikb.dev/resume.pdf", url: "https://erikb.dev/resume.pdf")

              Text(
                """
                Software developer who builds applications using Swift and modern web technologies.
                Currently working on `\(Text("$ ssh erikb.dev").foregroundStyle(.yellow).bold())`.
                """
              )
              .padding(.top, 1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
          }
          .safeAreaPadding(.top, 1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 1)
  }

  private func row(label: String, value: String, url: String? = nil) -> some View {
    HStack(spacing: 0) {
      Text("\(label): ")
        .foregroundStyle(.yellow)
      if let url, !url.isEmpty {
        Link(value, destination: LinkDestination(url))
      } else {
        Text(value)
      }
    }
  }
}
