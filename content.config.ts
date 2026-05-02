import { defineCollection, defineContentConfig } from "@nuxt/content";
import { z } from "zod";

const PostHeader = z.discriminatedUnion("type", [
  z.object({
    type: z.literal("code"),
    lang: z.string(),
    value: z.string(),
  }),
  z.object({
    type: z.literal("video"),
    src: z.string(),
    label: z.string(),
  }),
  z.object({
    type: z.literal("link"),
    href: z.string(),
  }),
  z.object({
    type: z.literal("image"),
    src: z.string(),
    label: z.string(),
  }),
]);

const PostLink = z.object({
  label: z.string(),
  href: z.string(),
  role: z.enum(["primary", "secondary"]),
});

export default defineContentConfig({
  collections: {
    devLogs: defineCollection({
      type: "page",
      source: "dev-logs/*.md",
      schema: z.object({
        title: z.string(),
        date: z.string(),
        kind: z.string(),
        header: PostHeader.optional(),
        links: z.array(PostLink),
      }),
    }),
  },
});
