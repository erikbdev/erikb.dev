<script setup lang="ts">
import { PhMapPin, PhNavigationArrow, PhWaveform, PhArrowSquareOut } from "@phosphor-icons/vue";
import { onMounted, type Component } from "vue";

import BlockSection from "@/components/BlockSection.vue";
import { useActivity } from "@/composables/use-activity";
import { useCodeLang } from "@/composables/use-codelang";
import { useHighlight } from "@/composables/use-highlight";

const { activity, fetchActivity } = useActivity();
const { codeLang, allCodeLangs } = useCodeLang();
const { highlightAll } = useHighlight();

// const posts = Object.freeze(
//   (Object.values(import.meta.glob("../../posts/*.md", { eager: true })) as ImportPost[])
//     .map((p) => ({ ...p, date: new Date(p.date) }))
//     .sort((p1, p2) => p1.date.getTime() - p2.date.getTime())
//     .map((p, i) => ({ ...p, id: `logs-${i}`, index: i }))
//     .reverse(),
// );

const posts = await useAsyncData("dev-logs", () => queryCollection("devLogs").all()).then((p) => p.data);

const postDateFormatter = new Intl.DateTimeFormat("en-US", {
  month: "short",
  day: "numeric",
  year: "numeric",
});

onMounted(() => {
  fetchActivity();
  highlightAll();
});
</script>
<template>
  <!-- Intro -->
  <BlockSection id="user">
    <header>
      <div class="w-full text-sm text-end text-neutral-500 mb-2">
        <a href="#user">
          <code>{{ codeLang.fileCase("user") }}</code>
        </a>
      </div>
      <h1 class="text-3xl font-bold mb-1.5"><span class="text-neutral-500">#</span> Erik Bautista Santibanez</h1>
      <p class="mb-1">Mobile & Web Developer</p>
      <p class="text-neutral-300">
        <PhMapPin weight="fill" class="text-white inline-block mr-1 size-[1em] mb-1" />
        <span>Irvine, CA</span>
      </p>
      <p v-if="!!activity?.location?.city || !!activity?.location?.state || !!activity?.location?.region" class="text-neutral-300">
        <PhNavigationArrow weight="fill" mirrored class="text-white inline-block mr-1 size-[1em] mb-1" />
        <span>Currently in </span>
        <span class="font-bold italic text-white">{{ [activity.location.city || "", activity.location.state || "", activity.location.region || ""].filter((s) => !!s).join(", ") }}</span>
      </p>
      <p v-if="activity?.nowPlaying" class="text-neutral-300">
        <PhWaveform mirrored class="text-white inline-block mr-1 size-[1em] mb-1" />
        <span>Listening to </span>
        <span class="font-bold italic text-white">{{ [activity.nowPlaying.title, activity.nowPlaying.artist || ""].join(" — ") }}</span>
      </p>
      <p class="pt-3 pb-5" :class="codeLang.id !== 'md' ? 'text-neutral-300' : ''">{{ codeLang.id !== "md" ? "// " : "" }}I'm a passionate software developer who builds applications using Swift and modern web technologies.</p>
      <div class="flex flex-row flex-wrap gap-2 text-sm text-white">
        <a href="mailto:me@erikb.dev" class="border border-border px-3 py-2">
          <code v-if="codeLang.id == 'md'">[email](me@erikb.dev)</code>
          <code v-else>user.email() <span class="text-neutral-500">// me@erikb.dev</span></code>
        </a>
        <a href="https://github.com/erikbdev" class="border border-border px-3 py-2 bg-white text-black">
          <code v-if="codeLang.id == 'md'">[github](/erikbdev)</code>
          <code v-else>user.github() <span class="text-neutral-700">// erikbdev</span></code>
        </a>
        <a href="https://linkedin.com/erik-bautista" class="border border-border px-3 py-2 bg-white text-black">
          <code v-if="codeLang.id == 'md'">[linkedin](/erikbautista)</code>
          <code v-else>user.linkedin() <span class="text-neutral-700">// erikbautista</span></code>
        </a>
      </div>
    </header>
  </BlockSection>

  <!-- Dev Logs -->
  <BlockSection id="dev-logs" class="p-0!">
    <header class="p-6">
      <div class="w-full text-sm text-end text-neutral-500 mb-2">
        <a href="#dev-logs">
          <code>{{ codeLang.fileCase("dev-logs") }}</code>
        </a>
      </div>
      <h1 class="text-3xl font-bold mb-1.5"><span class="text-neutral-500">#</span> Dev Logs</h1>
      <p>A curated list of projects I've worked on.</p>
    </header>
    <article v-for="(post, index) in posts" class="p-6 border-t border-border border-dashed" :key="post.id" :id="post.id">
      <header class="w-full">
        <hgroup class="mb-6 text-sm text-neutral-500 flex flex-row justify-between items-center">
          <span class="font-semibold">{{ postDateFormatter.format(new Date(post.date)) }}</span>
          <a :href="`#${post.id}`">
            <code v-if="codeLang.id == 'md'">{{ codeLang.fileCase(`logs-${index}`) }}</code>
            <code v-else>{{ `logs[${index}]` }}</code>
          </a>
        </hgroup>
      </header>
      <ContentRenderer tag="section" :value="post" class="w-full max-w-none prose text-lg prose-headings:text-2xl! prose-p:text-white prose-invert mt-3" />
      <footer v-if="!!post.links?.length" class="mt-6 flex flex-row flex-wrap gap-2 text-sm font-medium text-white">
        <a v-for="link in post.links || []" :class="['border border-border px-3 py-2', link.role == 'secondary' ? 'bg-white text-black' : '']" :href="link.href" target="_blank" rel="noopener noreferrer">
          <span>{{ link.label }}</span>
          <PhArrowSquareOut weight="bold" class="inline-block ml-1 size-[1em] mb-0.5" />
        </a>
      </footer>
    </article>
  </BlockSection>
</template>
