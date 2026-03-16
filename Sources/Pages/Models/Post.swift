struct Post: Sendable {
  enum Header {
    case link(String)
    case image(String, label: String)
    case video(String)
    case code(String, lang: CodeLang)
  }

  enum Kind: String, Hashable, CaseIterable {
    case blog
    case project
    case education
    case experience

    var tabTitle: String {
      switch self {
      case .blog: "Blog"
      case .project: "Projects"
      case .education: "Education"
      case .experience: "Experiences"
      }
    }
  }

  struct Date: Hashable, Comparable {
    let month: Int
    let day: Int
    let year: Int

    static func < (lhs: Post.Date, rhs: Post.Date) -> Bool {
      (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day) 
    }
  }

  struct Link {
    enum Role: String, CaseIterable {
      case primary
      case secondary
    }

    let title: String
    let href: String
    let role: Role

    var isExternal: Bool { !self.href.hasPrefix("/") }
  }

  var header: Header?
  let title: String
  let content: String
  let date: Date
  var lastUpdated: Date?
  let kind: Kind
  var links: [Link] = []
  var hidden = false

  var datePosted: String {
    "\(self.date.month)/\(self.date.day)/\(self.date.year)"
  }

  var dateUpdated: String? {
    if let lastUpdated {
      "\(lastUpdated.month)/\(lastUpdated.day)/\(lastUpdated.year)"
    } else {
      nil
    }
  }

  var slug: String {
    "\(self.date.year)\(self.date.month)\(self.date.day)-\(self.title.split { !$0.isLetter && !$0.isNumber }.joined(separator: "-").lowercased())"
  }
}
