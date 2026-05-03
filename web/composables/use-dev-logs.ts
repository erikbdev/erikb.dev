import type { MDCRoot } from "@nuxtjs/mdc";

type PostHeader = { type: "code"; lang: string; value: string } | { type: "video"; src: string; label: string } | { type: "link"; href: string } | { type: "image"; src: string; label: string };

type PostLink = { label: string; href: string; role: "primary" | "secondary" };

type PostMetadata = {
  title: string;
  description: string;
  date: string;
  kind: string;
  header?: PostHeader;
  links?: PostLink[];
};

export type Post = Omit<PostMetadata, "date"> & {
  id: string;
  index: number;
  date: Date;
  path: string;
  body: MDCRoot;
};

export async function useDevLogs() {
  return await useAsyncData("dev-logs", async () => {
    const rawPosts = import.meta.glob("../../posts/*.md", {
      eager: true,
      query: "?raw",
      import: "default",
    });

    const posts: Post[] = [];

    for (const pair of Object.entries(rawPosts) as [string, string][]) {
      const md = await parseMarkdown(pair[1]);
      const metadata = md.data as PostMetadata;
      posts.push({
        ...metadata,
        body: md.body,
        id: "",
        index: 0,
        date: new Date(metadata.date),
        path: pair[0],
      } satisfies Post);
    }
    return posts
      .sort((p1, p2) => p1.date.getTime() - p2.date.getTime())
      .map((p, i) => ({ ...p, id: `logs-${i}`, index: i }))
      .reverse();
  });
}
