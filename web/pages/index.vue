<script setup lang="ts">
import PhMapPinSVG from "@phosphor-icons/core/fill/map-pin-fill.svg?raw";
import PhNavigationArrowSVG from "@phosphor-icons/core/fill/navigation-arrow-fill.svg?raw";
import PhWaveFormSVG from "@phosphor-icons/core/regular/waveform.svg?raw";

definePageMeta({
  name: "home",
  index: 0,
});

const { location, residency, nowPlaying, fetchActivity } = useActivity();
const { data: posts } = await useDevLogs();
const emailAddress = ref("");

const postDateFormatter = new Intl.DateTimeFormat("en-US", {
  month: "short",
  day: "numeric",
  year: "numeric",
});

onMounted(() => {
  if (import.meta.browser) {
    emailAddress.value = "me@erikb.dev";
    fetchActivity();
  }
});
</script>
<template>
  <!-- Intro -->
  <BlockSection id="user">
    <header>
      <NuxtLink to="#user" class="inline-block text-xs text-start text-white mb-5"> <span class="text-terminal">$</span> cat profile.md </NuxtLink>

      <h1 class="text-3xl font-bold mb-1 text-white">Erik Bautista Santibanez</h1>

      <div class="space-y-1.5 mb-5 text-sm">
        <div class="flex gap-2">
          <span class="text-neutral-600 w-[3.5ch] flex-none">ROLE</span>
          <span class="text-neutral-700 flex-none select-none">···</span>
          <span class="text-neutral-300">Mobile &amp; Web Developer</span>
        </div>
        <div class="flex gap-2">
          <span class="text-neutral-600 w-[3.5ch] flex-none">LOC</span>
          <span class="text-neutral-700 flex-none select-none">···</span>
          <span class="text-neutral-400">
            <span class="inline-block size-[1em] align-middle" v-html="PhMapPinSVG"></span>
            {{ [residency.city, residency.state].join(", ") }}
          </span>
        </div>
        <div v-if="location" class="flex gap-2">
          <span class="text-neutral-600 w-[3.5ch] flex-none">NOW</span>
          <span class="text-neutral-700 flex-none select-none">···</span>
          <span class="text-white animate-pulse">
            <span class="inline-block mr-1 size-[1em] align-middle -scale-x-100" v-html="PhNavigationArrowSVG"></span>
            {{ [location.city || "", location.state || "", location.region || ""].filter((s) => !!s).join(", ") }}
          </span>
        </div>
        <div v-if="nowPlaying" class="flex gap-2">
          <span class="text-neutral-600 w-[3.5ch] flex-none">PLAY</span>
          <span class="text-neutral-700 flex-none select-none">···</span>
          <span class="text-white animate-pulse">
            <span class="inline-block mr-1 size-[1em] align-middle" v-html="PhWaveFormSVG"></span>
            {{ [nowPlaying.title, nowPlaying.artist || ""].join(" — ") }}
          </span>
        </div>
      </div>

      <p class="text-neutral-300 mb-4">I'm a passionate software developer who builds applications using Swift and modern web technologies.</p>

      <div class="flex flex-row flex-wrap gap-2 text-sm">
        <NuxtLink :to="`mailto:${emailAddress}`" class="border border-gridline px-3 py-2 text-neutral-500 hover:bg-terminal/10 transition-colors">
          {{ emailAddress || "email" }}
        </NuxtLink>
        <NuxtLink external to="/ebs-resume.pdf" class="border border-gridline px-3 py-2 text-neutral-500 hover:text-white hover:border-neutral-600 transition-colors"> /resume.pdf </NuxtLink>
        <NuxtLink external to="https://github.com/erikbdev" class="border border-gridline px-3 py-2 text-neutral-500 hover:text-white hover:border-neutral-600 transition-colors"> /github </NuxtLink>
        <NuxtLink external to="https://linkedin.com/erikbautista" class="border border-gridline px-3 py-2 text-neutral-500 hover:text-white hover:border-neutral-600 transition-colors"> /linkedin </NuxtLink>
      </div>
    </header>
  </BlockSection>

  <!-- Dev Logs -->
  <BlockSection id="dev-logs" class="p-0!">
    <header class="p-6">
      <NuxtLink to="#dev-logs" class="inline-block text-xs text-white mb-5"> <span class="text-terminal">$</span> cat dev-logs.md </NuxtLink>
      <h1 class="text-3xl font-bold mb-1.5 text-white">Dev Logs</h1>
      <p class="text-neutral-300">A curated list of projects I've worked on.</p>
    </header>
    <article v-for="post in posts" class="p-6 border-t border-gridline border-dashed" :key="post.id" :id="post.id">
      <header class="w-full">
        <hgroup class="mb-6 text-xs text-white flex flex-row justify-between items-center">
          <NuxtLink :to="`#${post.id}`"> <span class="text-terminal">$</span> cat log-{{ post.index }}.md </NuxtLink>
          <span class="text-neutral-700">{{ postDateFormatter.format(post.date) }}</span>
        </hgroup>
      </header>

      <MDCRenderer tag="section" :body="post.body" class="w-full max-w-none prose text-lg prose-headings:text-2xl! prose-p:text-neutral-300 prose-invert mt-3" />
      <footer v-if="!!post.links?.length" class="mt-6 flex flex-row flex-wrap gap-2 text-sm font-medium">
        <NuxtLink v-for="link in post.links || []" :class="['border px-3 py-2 transition-colors', link.role == 'secondary' ? 'border-terminal text-terminal hover:bg-terminal/10' : 'border-gridline text-neutral-500 hover:text-white hover:border-neutral-600']" :to="link.href" target="_blank" rel="noopener noreferrer">
          {{ link.label }}
        </NuxtLink>
      </footer>
    </article>
  </BlockSection>
</template>
