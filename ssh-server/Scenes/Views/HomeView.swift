import SwiftTUI

struct HomeView: View {
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 1) {
        VStack(alignment: .leading, spacing: 1) {
          Text("# Erik Bautista Santibanez")
            .bold()
          Text("Mobile & Web Developer")
          Text("Irvine, CA")
        }

        Text(
          "I'm a passionate software developer who builds applications using Swift and modern web technologies."
        )
        .foregroundStyle(.gray)

        Divider()

        VStack(alignment: .leading, spacing: 1) {
          Link("[/email](me@erikb.dev)", destination: "mailto:me@erikb.dev")
          Link("[/resume.pdf](/ebs-resume.pdf)", destination: "https://erikb.dev/ebs-resume.pdf")
          Link("[/github](/erikbdev)", destination: "https://github.com/erikbdev")
          Link("[/linkedin](/erikbautista)", destination: "https://linkedin.com/in/erikbautista")
        }
      }
      .padding()
    }
  }
}
