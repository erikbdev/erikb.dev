<script setup lang="ts">
definePageMeta({
  name: "Home",
  index: 0,
});

const { activity, fetchActivity } = useActivity();
const { codeLang, allCodeLangs } = useCodeLang();

const { data: posts } = await useDevLogs();

const postDateFormatter = new Intl.DateTimeFormat("en-US", {
  month: "short",
  day: "numeric",
  year: "numeric",
});

onMounted(() => {
  if (import.meta.browser) {
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
        <NuxtLink to="mailto:me@erikb.dev" class="border border-border px-3 py-2">
          <code v-if="codeLang.id == 'md'">[email](me@erikb.dev)</code>
          <code v-else>user.email() <span class="text-neutral-500">// me@erikb.dev</span></code>
        </NuxtLink>
        <NuxtLink to="https://github.com/erikbdev" class="border border-border px-3 py-2 bg-white text-black">
          <code v-if="codeLang.id == 'md'">[github](/erikbdev)</code>
          <code v-else>user.github() <span class="text-neutral-700">// erikbdev</span></code>
        </NuxtLink>
        <NuxtLink to="https://linkedin.com/erik-bautista" class="border border-border px-3 py-2 bg-white text-black">
          <code v-if="codeLang.id == 'md'">[linkedin](/erikbautista)</code>
          <code v-else>user.linkedin() <span class="text-neutral-700">// erikbautista</span></code>
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
          <PhArrowSquareOut weight="bold" class="inline-block ml-1 size-[1em] mb-0.5" />
        </NuxtLink>
      </footer>
    </article>
  </BlockSection>
</template>
