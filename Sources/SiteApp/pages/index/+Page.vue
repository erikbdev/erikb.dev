<script lang="ts" setup>
import BlockSection from "@/components/BlockSection.vue";
import useCodeLang from "@/stores/useCodeLang";
import { PhMapPin, PhNavigationArrow, PhWaveform } from "@phosphor-icons/vue";
import { onMounted } from "vue";

type PostHeader = {
  type: "code";
  lang: string;
  value: string;
} | {
  type: "video";
  src: string;
  label: string;
} | {
  type: "link";
  href: string;
} | {
  type: "image";
  src: string;
  label: string;
}

type PostLink = {
  label: string;
  href: string;
  role: "primary" | "secondary"
}

type Post = {
  title: string;
  date: Date;
  kind: string;
  header?: PostHeader;
  links: PostLink[];
  default: string;
}

const { codeLang, allCodeLangs } = useCodeLang();

const posts = (Object.values(import.meta.glob('../../posts/*.md', { eager: true })) as Post[])
  .map(p => {
    if (typeof p.date == "string") {
      return { ...p, date: new Date(p.date) }
    } else {
      return p;
    }
  })
  .sort((p1, p2) => p2.date.getTime() - p1.date.getTime())

const postDateFormatter = new Intl.DateTimeFormat('en-US', {
  month: "short",
  day: "numeric",
  year: "numeric"
});
</script>
<template>
  <!-- Intro -->
  <BlockSection id="user">
    <header>
      <div class="w-full text-sm text-end text-neutral-500 mb-2">
        <a href="#user">
          <code>{{ codeLang.fileCase('user') }}</code>
        </a>
      </div>
      <h1 class="text-3xl font-bold mb-1.5">
        <span class="text-neutral-500">#</span> Erik Bautista Santibanez
      </h1>
      <p class="text-neutral-300">Mobile & Web Developer</p>
      <p class="text-neutral-300">
        <PhMapPin weight="fill" class="text-white inline-block mr-1 size-[1em] mb-1" />
        <span>Irvine, CA</span>
      </p>
      <p class="text-neutral-300">
        <PhNavigationArrow weight="fill" mirrored class="text-white inline-block mr-1 size-[1em] mb-1" />
        <span>Currently in </span>
        <span class="font-bold italic text-white">Irvine, CA</span>
      </p>
      <p class="text-neutral-300">
        <PhWaveform mirrored class="text-white inline-block mr-1 size-[1em] mb-1" />
        <span>Listening to </span>
        <span class="font-bold italic text-white">TODO CAMBIÓ — DannyLux</span>
      </p>
      <p class="text-neutral-300 pt-4 pb-5">
        I'm a passionate software developer who builds applications using Swift and modern web
        technologies.
      </p>
      <div class="flex flex-row flex-wrap gap-2 text-sm text-white">
        <button class="border border-border px-3 py-2">
          <code v-if="codeLang.id == allCodeLangs.md.id">[email](me@erikb.dev)</code>
          <code v-else>user.email() <span class="text-neutral-500">// me@erikb.dev</span></code>
        </button>
        <button class="border border-border px-3 py-2 bg-white text-black">
          <code v-if="codeLang.id == allCodeLangs.md.id">[github](/erikbdev)</code>
          <code v-else>user.github() <span class="text-neutral-700">// erikbdev</span></code>
        </button>
        <button class="border border-border px-3 py-2 bg-white text-black">
          <code v-if="codeLang.id == allCodeLangs.md.id">[linkedin](/erikbautista)</code>
          <code v-else>user.linkedin() <span class="text-neutral-700">// erikbautista</span></code>
        </button>
      </div>
    </header>
  </BlockSection>

  <!-- Dev Logs -->
  <BlockSection id="dev-logs">
    <header>
      <div class="w-full text-sm text-end text-neutral-500 mb-2">
        <a href="#dev-logs">
          <code>{{ codeLang.fileCase('dev-logs') }}</code>
        </a>
      </div>
      <h1 class="text-3xl font-bold mb-1.5">
        <span class="text-neutral-500">#</span> Dev Logs
      </h1>
      <p class="text-neutral-300">A curated list of projects I've worked on.</p>
    </header>
    <article v-for="post, index in posts" class="py-4">
      <header class="w-full text-sm text-neutral-500 mb-2">
        <hgroup class="flex flex-row justify-between items-center">
          <span class="font-semibold">{{ postDateFormatter.format(post.date) }}</span>
          <a :href="`#log-${posts.length - index - 1}`">
            <code>{{ `log-${posts.length - index - 1}.md` }}</code>
          </a>
        </hgroup>
      </header>
      <h3 class="text-xl font-bold mb-2">{{ post.title }}</h3>
      <component :is="post.default"></component>
      <footer v-if="!!post.links" class="flex flex-row flex-wrap gap-2 text-sm text-white mt-4">
        <button v-for="link in post.links || []" class="border border-border px-3 py-2 font-semibold">
           {{ link.label }}
        </button>
      </footer>
    </article>
  </BlockSection>
</template>
