import SwiftTUI

struct DevLogsView: View {
  @State private var selectedPost: Post? = nil
  @State private var showingDetail = false

  var body: some View {
    NavigationStack {
      postList
        .navigationDestination(isPresented: $showingDetail) {
          if let post = selectedPost {
            PostDetailView(post: post) {
              showingDetail = false
            }
          }
        }
    }
  }

  private var postList: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 1) {
        HStack(spacing: 1) {
          Text("$").bold().foregroundStyle(.green)
          Text("ls -l /dev-logs/").bold()
        }

        Divider()

        VStack(alignment: .leading, spacing: 1) {
          Text("Dev Logs").bold()
          Text("A curated list of projects I've worked on.").foregroundStyle(.gray)
        }

        Divider()

        VStack(alignment: .leading, spacing: 0) {
          ForEach(Post.all) { post in
            PostRowView(post: post) {
              selectedPost = post
              showingDetail = true
            }
            Divider()
          }
        }
      }
      .padding()
    }
  }
}

// MARK: - Post row

private struct PostRowView: View {
  let post: Post
  let onSelect: @MainActor () -> Void

  var body: some View {
    Button(action: onSelect) {
      VStack(alignment: .leading, spacing: 0) {
        HStack {
          Text("$ cat log-\(post.index).md")
            .bold()
            .foregroundStyle(.green)
          Spacer()
          Text(post.formattedDate)
            .foregroundStyle(.gray)
        }
        Text(post.title)
          .padding(.top, 1)
        Text(post.kind.rawValue)
          .foregroundStyle(.gray)
          .padding(.bottom, 1)
      }
    }
    .buttonStyle(.plain)
  }
}

// MARK: - Post detail

struct PostDetailView: View {
  let post: Post
  let dismiss: @MainActor () -> Void

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 1) {
        HStack(spacing: 1) {
          Text("$").bold().foregroundStyle(.green)
          Text("cat log-\(post.index).md").bold()
        }

        Divider()

        VStack(alignment: .leading, spacing: 1) {
          Text(post.title).bold()
          HStack(spacing: 0) {
            Text(post.formattedDate).foregroundStyle(.gray)
            Text("  ·  ").foregroundStyle(.gray)
            Text(post.kind.rawValue).foregroundStyle(.gray)
          }
        }

        Divider()

        Text(post.body)

        if !post.links.isEmpty {
          Divider()
          VStack(alignment: .leading, spacing: 1) {
            ForEach(Array(post.links.enumerated()), id: \.offset) { _, link in
              Link(link.label, destination: LinkDestination(link.href))
            }
          }
        }

        Divider()

        Button("< back") {
          dismiss()
        }
      }
      .padding()
    }
  }
}
