import SwiftTUI

struct HomeView: View {
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 1) {
        HStack(spacing: 1) {
          Text("$").bold().foregroundStyle(.green)
          Text("whoami").bold()
        }

        Divider()

        VStack(alignment: .leading, spacing: 1) {
          Text("Erik Bautista Santibanez").bold()
          Text("Mobile & Web Developer")
          Text("Irvine, CA").foregroundStyle(.gray)
        }

        Divider()

        Text(
          "I'm a passionate software developer who builds applications using Swift and modern web technologies."
        )

        Divider()

        VStack(alignment: .leading, spacing: 1) {
          Link("/me@erikb.dev", destination: "mailto:me@erikb.dev")
          Link("/resume.pdf", destination: "https://erikb.dev/ebs-resume.pdf")
          Link("/github", destination: "https://github.com/erikbdev")
          Link("/linkedin", destination: "https://linkedin.com/in/erikbautista")
        }
      }
      .padding()
    }
  }
}
