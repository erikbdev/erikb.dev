import SwiftTUI
import Shared

// TODO: dynamically fetch all posts from api and cache?
struct DevLogsView: View {
  @State private var selectedPost: Post? = nil

  var body: some View {
    NavigationStack {
      VStack(alignment: .leading, spacing: 0) {
        VStack(alignment: .leading, spacing: 0) {
          Text("\(Text("$").foregroundStyle(.yellow)) ls -l dev-logs/")
          Text("a curated lists of projects i've worked on")
            .foregroundStyle(.gray)
        }
        .padding(.horizontal, 1)

        ScrollView(.vertical) {
          VStack(alignment: .leading, spacing: 0) {
            ForEach(Post.published) { post in
              Divider()
                .padding(0)
              PostRowView(post: post) {
                selectedPost = post
              }

              if Post.published.last?.id == post.id {
                Divider()
                  .padding(0)
              }
            }
          }
        }
      }
      .navigationDestination(item: $selectedPost) { post in
        PostDetailView(post: post) {
          self.selectedPost = nil
        }
      }
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
          Text("\(post.id).md")
            .foregroundStyle(.yellow.opacity(0.5))
            .frame(maxWidth: .infinity, alignment: .leading)
          Text(post.formattedDate)
            .foregroundStyle(.gray)
        }
        Text(post.title)
        Text(post.kind.rawValue)
          .foregroundStyle(.gray)
      }
      .padding(.trailing, 1)
    }
    .buttonStyle(.plain)
    .padding(0)
  }
}

// MARK: - Post detail

struct PostDetailView: View {
  let post: Post
  let dismiss: @MainActor () -> Void

  var body: some View {
    ScrollView(.vertical) {
      VStack(alignment: .leading, spacing: 1) {
        Text("\(Text("$").foregroundStyle(.yellow)) cat \(post.id).md")

        HStack(spacing: 2) {
          Text("# \(post.title)")
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
          Text(post.formattedDate)
            .foregroundStyle(.gray)
        }

        Text(post.markdownBody)

        if !post.links.isEmpty {
          HStack(spacing: 1) {
            ForEach(Array(post.links.enumerated()), id: \.offset) { _, link in
              Link(Text(link.label).foregroundStyle(.yellow), destination: LinkDestination(link.href))
                .border(.yellow)
            }
          }
        }

        Button("← back") {
          dismiss()
        }
        .buttonStyle(.bordered)
      }
    }
    .safeAreaPadding(.horizontal, 1)
  }
}
