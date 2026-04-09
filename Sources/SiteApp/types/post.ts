import type { CodeLang } from './codeLang';

export type PostKind = 'blog' | 'project' | 'education' | 'experience';

export interface PostTextContent {
  content: (TextElement | LinkElement)[];
}

export interface TextElement {
  type: 'text';
  value: string;
}

export interface LinkElement {
  type: 'link';
  title: string;
  url: string;
}

export type PostHeader =
  | { type: 'image'; src: string; label: string }
  | { type: 'video'; src: string; mime: string }
  | { type: 'code'; code: string; lang: CodeLang };

export interface PostLink {
  title: string;
  href: string;
  role: 'primary' | 'secondary';
}

export interface PostDate {
  month: number;
  day: number;
  year: number;
}

export interface Post {
  header?: PostHeader;
  title: PostTextContent;
  content: PostTextContent;
  date: PostDate;
  kind: PostKind;
  links?: PostLink[];
  lastUpdated?: PostDate;
  hidden?: boolean;

  // computed
  datePosted: string;
  dateUpdated?: string;
  slug: string;
}

// Helper to format date
function formatDate(date: PostDate): string {
  return `${date.month}/${date.day}/${date.year}`;
}

// Helper to compute slug
function computeSlug(title: PostTextContent, date: PostDate): string {
  const titleStr = textContentToString(title);
  const slug = titleStr
    .toLowerCase()
    .split(/[^a-z0-9]+/)
    .filter((s) => s.length > 0)
    .join('-');
  return `${date.year}${date.month}${date.day}-${slug}`;
}

// Helper to extract plain text from TextContent
function textContentToString(content: PostTextContent): string {
  return content.content
    .map((el) => (el.type === 'text' ? el.value : el.title))
    .join('');
}

// Helper to create a Post object with computed fields
function createPost(base: Omit<Post, 'datePosted' | 'slug' | 'dateUpdated'>): Post {
  return {
    ...base,
    datePosted: formatDate(base.date),
    dateUpdated: base.lastUpdated ? formatDate(base.lastUpdated) : undefined,
    slug: computeSlug(base.title, base.date)
  };
}

// Static post data (ported from Post+AllCases.swift)
export const posts: Post[] = [
  createPost({
    header: {
      type: 'video',
      src: '/assets/posts/wled-app-demo/video.webm',
      mime: 'video/webm'
    },
    title: {
      content: [{ type: 'text', value: 'A WLED Client for iOS' }]
    },
    content: {
      content: [
        { type: 'text', value: 'I built a native iOS app for ' },
        { type: 'link', title: 'WLED', url: 'https://github.com/wled/WLED' },
        { type: 'text', value: ', an open-source LED controller for ESP32, to control my RGB LED strips.' }
      ]
    },
    date: { month: 8, day: 4, year: 2022 },
    kind: 'project',
    links: []
  }),
  createPost({
    title: {
      content: [{ type: 'text', value: 'PrismUI — Controlling MSI RGB Keyboard on macOS' }]
    },
    content: {
      content: [
        { type: 'text', value: 'When I configured my Hackintosh, I was unable to control the RGB keyboard on my MSI laptop due to the software only being supported on Windows. To resolve this issue, my first approach was to build an app using AppKit, C++, and Objective-C to communicate with the HID keyboard, which was ultimately called ' },
        { type: 'link', title: 'SSKeyboardHue', url: 'https://github.com/erikbdev/SSKeyboardHue' },
        { type: 'text', value: '.\n\nLater, I decided to switch the communication protocol to Swift and redesign the front end using SwiftUI.\n\nBoth projects are available on GitHub — feel free to check them out!' }
      ]
    },
    date: { month: 8, day: 8, year: 2021 },
    kind: 'project',
    links: [
      {
        title: 'PrismUI on GitHub',
        href: 'https://github.com/erikbdev/PrismUI',
        role: 'primary'
      },
      {
        title: 'SSKeyboardHue on GitHub',
        href: 'https://github.com/erikbdev/SSKeyboardHue',
        role: 'secondary'
      }
    ]
  }),
  createPost({
    header: {
      type: 'image',
      src: '/assets/posts/anime-now-released/an-discover.webp',
      label: 'Anime Now! discover image'
    },
    title: {
      content: [{ type: 'text', value: 'Anime Now! — An iOS and macOS App' }]
    },
    content: {
      content: []
    },
    date: { month: 9, day: 15, year: 2022 },
    kind: 'project'
  }),
  createPost({
    title: {
      content: [{ type: 'text', value: 'Mochi — Content Viewer for iOS and macOS' }]
    },
    content: {
      content: []
    },
    date: { month: 12, day: 10, year: 2023 },
    kind: 'project',
    links: [
      {
        title: 'Mochi Website',
        href: 'https://mochi.erikb.dev',
        role: 'primary'
      }
    ]
  }),
  createPost({
    header: {
      type: 'code',
      code: 'struct Portfolio: HTML {\n  var body: some HTML {\n    HomePage()\n  }\n}',
      lang: 'swift'
    },
    title: {
      content: [{ type: 'text', value: 'Website Redesign' }]
    },
    content: {
      content: [
        { type: 'text', value: 'I redesigned my website, but instead of using traditional web frameworks, I used Swift! I\'ve also built a library called ' },
        { type: 'link', title: 'swift-web', url: 'https://github.com/erikbdev/swift-web' },
        { type: 'text', value: ' which contains tools used to build this website.\n\nFeel free to check out both projects on GitHub. 😊' }
      ]
    },
    date: { month: 2, day: 2, year: 2025 },
    kind: 'blog',
    links: [
      {
        title: 'Portfolio on GitHub',
        href: 'https://github.com/erikbdev/erikbautista.dev',
        role: 'primary'
      },
      {
        title: 'swift-web on GitHub',
        href: 'https://github.com/erikbdev/swift-web',
        role: 'secondary'
      }
    ]
  }),
  createPost({
    title: {
      content: [{ type: 'text', value: 'xtool is Awesome!' }]
    },
    content: {
      content: [
        { type: 'link', title: 'xtool', url: 'https://github.com/xtool-org/xtool' },
        { type: 'text', value: ' is a tool that attempts to replace Xcode by using Swift Package Manager to build and deploy iOS apps on macOS, Linux, and Windows! I have been working closely with the developer to support for App Extensions and also resolve additional issues.\n\nI hope to also replace "AppleProductTypes", a library used to build iOS and macOS apps using Swift Playgrounds, in favor of "XToolProductTypes."' }
      ]
    },
    date: { month: 7, day: 20, year: 2025 },
    kind: 'blog',
    links: [
      {
        title: 'xtool on GitHub',
        href: 'https://github.com/xtool-org/xtool',
        role: 'primary'
      }
    ]
  })
].sort((a, b) => {
  const aDate = a.date;
  const bDate = b.date;
  const aNum = aDate.year * 10000 + aDate.month * 100 + aDate.day;
  const bNum = bDate.year * 10000 + bDate.month * 100 + bDate.day;
  return aNum - bNum;
});
