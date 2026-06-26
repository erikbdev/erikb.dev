import SwiftTUI

struct HomeView: View {

  var body: some View {
    ScrollView {
      HStack(alignment: .top, spacing: 2) {
        VStack(alignment: .leading, spacing: 2) {
          VStack(alignment: .leading, spacing: 0) {
            row(label: "name", value: "Erik Bautista Santibanez")
            row(label: "role", value: "Mobile & Web Developer")
            row(label: "from", value: "Irvine, CA")
            row(label: "tech", value: "Swift · TypeScript")
          }

          Text(
            "I'm a passionate software developer who builds applications using Swift and modern web technologies."
          )

          VStack(alignment: .leading, spacing: 1) {
            Link("[/email](me@erikb.dev)", destination: "mailto:me@erikb.dev")
            Link("[/resume.pdf](/ebs-resume.pdf)", destination: "https://erikb.dev/ebs-resume.pdf")
            Link("[/github](/erikbdev)", destination: "https://github.com/erikbdev")
            Link("[/linkedin](/erikbautista)", destination: "https://linkedin.com/in/erikbautista")
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        SpinnerView()
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
