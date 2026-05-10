<script setup lang="ts">
import PhArrowSquareOutSVG from "@phosphor-icons/core/bold/arrow-square-out-bold.svg?raw";
import PhMapPinSVG from "@phosphor-icons/core/fill/map-pin-fill.svg?raw";
import PhNavigationArrowSVG from "@phosphor-icons/core/fill/navigation-arrow-fill.svg?raw";
import PhWaveFormSVG from "@phosphor-icons/core/regular/waveform.svg?raw";

definePageMeta({
  name: "Home",
  index: 0,
});

const { location, residency, nowPlaying, fetchActivity } = useActivity();
const { codeLang, allCodeLangs } = useCodeLang();

const { data: posts } = await useDevLogs();
const showEmail = ref(false);

const postDateFormatter = new Intl.DateTimeFormat("en-US", {
  month: "short",
  day: "numeric",
  year: "numeric",
});

onMounted(() => {
  if (import.meta.browser) {
    // only show on mounted.
    showEmail.value = true;
    fetchActivity();
  }
});
</script>
<template>
  <!-- Intro -->
  <BlockSection id="user">
    <header>
      <div class="w-full text-sm text-end text-neutral-500 mb-2">
        <NuxtLink to="#user">
          <code>{{ codeLang.fileCase("user") }}</code>
        </NuxtLink>
      </div>
      <h1 class="text-3xl font-bold mb-1.5"><span class="text-neutral-500">#</span> Erik Bautista Santibanez</h1>
      <p class="mb-1">Mobile & Web Developer</p>
      <p class="text-neutral-300">
        <span class="text-white inline-block mr-1 size-[1em]" v-html="PhMapPinSVG"></span>
        <span>{{ [residency.city, residency.state].join(", ") }}</span>
      </p>
      <p v-if="location" class="text-neutral-300">
        <span class="text-white inline-block mr-1 size-[1em] -scale-x-100 animate-pulse" v-html="PhNavigationArrowSVG"></span>
        <span>Currently in </span>
        <span class="font-bold italic text-white">{{ [location.city || "", location.state || "", location.region || ""].filter((s) => !!s).join(", ") }}</span>
      </p>
      <p v-if="nowPlaying" class="text-neutral-300">
        <span class="text-white inline-block mr-1 size-[1em] animate-pulse" v-html="PhWaveFormSVG"></span>
        <span>Listening to </span>
        <span class="font-bold italic text-white">{{ [nowPlaying.title, nowPlaying.artist || ""].join(" — ") }}</span>
      </p>
      <p class="pt-3 pb-5" :class="codeLang.id !== 'md' ? 'text-neutral-300' : ''">{{ codeLang.id !== "md" ? "// " : "" }}I'm a passionate software developer who builds applications using Swift and modern web technologies.</p>
      <div class="flex flex-row flex-wrap gap-2 text-sm text-white">
        <NuxtLink external to="/ebs-resume.pdf" class="border border-border px-3 py-2">
          <code v-if="codeLang.id == 'md'">[resume](ebs-resume.pdf)</code>
          <code v-else>user.resume() <span class="text-neutral-500">// ebs-resume.pdf</span></code>
        </NuxtLink>
        <NuxtLink :to="`mailto:${showEmail ? 'me@erikb.dev' : ''}`" class="border border-border px-3 py-2 bg-white text-black">
          <code v-if="codeLang.id == 'md'">[email]{{ showEmail ? "(me@erikb.dev)" : "" }}</code>
          <code v-else
            >user.email() <span class="text-neutral-700">{{ showEmail ? "// me@erikb.dev" : "" }}</span></code
          >
        </NuxtLink>
        <NuxtLink to="https://github.com/erikbdev" class="border border-border px-3 py-2 bg-white text-black">
          <code v-if="codeLang.id == 'md'">[github](/erikbdev)</code>
          <code v-else>user.github() <span class="text-neutral-700">// @erikbdev</span></code>
        </NuxtLink>
        <NuxtLink to="https://linkedin.com/erikbautista" class="border border-border px-3 py-2 bg-white text-black">
          <code v-if="codeLang.id == 'md'">[linkedin](/erikbautista)</code>
          <code v-else>user.linkedin() <span class="text-neutral-700">// @erikbautista</span></code>
        </NuxtLink>
      </div>
    </header>
  </BlockSection>

  <!-- Dev Logs -->
  <!-- TODO: move to /dev-logs -->
  <BlockSection id="dev-logs" class="p-0!">
    <header class="p-6">
      <div class="w-full text-sm text-end text-neutral-500 mb-2">
        <NuxtLink to="#dev-logs">
          <code>{{ codeLang.fileCase("dev-logs") }}</code>
        </NuxtLink>
      </div>
      <h1 class="text-3xl font-bold mb-1.5"><span class="text-neutral-500">#</span> Dev Logs</h1>
      <p>A curated list of projects I've worked on.</p>
    </header>
    <article v-for="post in posts" class="p-6 border-t border-border border-dashed" :key="post.id" :id="post.id">
      <header class="w-full">
        <hgroup class="mb-6 text-sm text-neutral-500 flex flex-row justify-between items-center">
          <span class="font-semibold">{{ postDateFormatter.format(post.date) }}</span>
          <NuxtLink :to="`#${post.id}`">
            <code v-if="codeLang.id == 'md'">{{ codeLang.fileCase(`log-${post.index}`) }}</code>
            <code v-else>{{ `logs[${post.index}]` }}</code>
          </NuxtLink>
        </hgroup>
      </header>

      <MDCRenderer tag="section" :body="post.body" class="w-full max-w-none prose text-lg prose-headings:text-2xl! prose-p:text-white prose-invert mt-3" />
      <footer v-if="!!post.links?.length" class="mt-6 flex flex-row flex-wrap gap-2 text-sm font-medium text-white">
        <NuxtLink v-for="link in post.links || []" :class="['border border-border px-3 py-2', link.role == 'secondary' ? 'bg-white text-black' : '']" :to="link.href" target="_blank" rel="noopener noreferrer">
          <span>{{ link.label }}</span>
          <span class="inline-block ml-1 size-[1em]" v-html="PhArrowSquareOutSVG"></span>
        </NuxtLink>
      </footer>
    </article>
  </BlockSection>
</template>
