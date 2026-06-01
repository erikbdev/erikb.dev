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

onMounted(async () => {
  if (import.meta.browser) {
    emailAddress.value = "me@erikb.dev";
    await fetchActivity();
  }
});
</script>
<template>
  <!-- Intro -->
  <BlockSection id="user">
    <header class="text-xineutral-50">
      <NuxtLink to="#user" class="text-sm inline-block text-start text-neutral-50 mb-5"> <span class="text-terminal">$</span> whoami </NuxtLink>

      <h1 class="text-3xl font-bold">Erik Bautista Santibanez</h1>

      <p class="text-white">Mobile & Web Developer</p>
      <p>
        <span class="inline-block size-[1em] align-middle text-white" v-html="PhMapPinSVG"></span>
        {{ [residency.city, residency.state].join(", ") }}
      </p>
      <p v-if="location">
        <span class="inline-block size-[1em] align-middle -scale-x-100 text-white animation-pulse" v-html="PhNavigationArrowSVG"></span>
        Currently in
        <span class="italic font-medium text-white">{{ [location.city || "", location.state || "", location.region || ""].filter((s) => !!s).join(", ") }}</span>
      </p>
      <p v-if="nowPlaying">
        <span class="inline-block size-[1em] align-middle text-white animate-pulse" v-html="PhWaveFormSVG"></span>
        Listening to
        <span class="font-bold text-white">{{ [nowPlaying.title, nowPlaying.artist || ""].join(" — ") }}</span>
      </p>

      <p class="my-4">I'm a passionate software developer who builds applications using Swift and modern web technologies.</p>

      <div class="flex flex-row flex-wrap gap-2">
        <NuxtLink external :to="`mailto:${emailAddress}`" class="border border-gridline px-3 py-2 hover:text-white hover:border-neutral-600 transition-colors"> /{{ emailAddress || "email" }} </NuxtLink>
        <NuxtLink external target="blank" to="/ebs-resume.pdf" class="border border-gridline px-3 py-2 hover:text-white hover:border-neutral-600 transition-colors"> /resume.pdf </NuxtLink>
        <NuxtLink external target="blank" to="https://github.com/erikbdev" class="border border-gridline px-3 py-2 hover:text-white hover:border-neutral-600 transition-colors"> /github </NuxtLink>
        <NuxtLink external target="blank" to="https://linkedin.com/erikbautista" class="border border-gridline px-3 py-2 hover:text-white hover:border-neutral-600 transition-colors"> /linkedin </NuxtLink>
      </div>
    </header>
  </BlockSection>

  <!-- Dev Logs -->
  <BlockSection id="dev-logs" class="p-0!">
    <header class="p-8">
      <NuxtLink to="#dev-logs" class="text-sm inline-block text-white mb-5"> <span class="text-terminal">$</span> ls -l /dev-logs/ </NuxtLink>
      <h1 class="text-3xl font-bold mb-1.5 text-white">Dev Logs</h1>
      <p class="text-neutral-300">A curated list of projects I've worked on.</p>
    </header>
    <article v-for="post in posts" class="p-8 border-t border-gridline border-dashed" :key="post.id" :id="post.id">
      <header class="w-full">
        <hgroup class="text-sm mb-6 text-white flex flex-row justify-between items-center">
          <NuxtLink :to="`#${post.id}`"> <span class="text-terminal">$</span> cat log-{{ post.index }}.md </NuxtLink>
          <span class="text-neutral-700">{{ postDateFormatter.format(post.date) }}</span>
        </hgroup>
      </header>

      <MDCRenderer tag="section" :body="post.body" class="w-full max-w-none prose prose-headings:text-xl prose-p:text-neutral-300 prose-invert mt-3" />

      <footer v-if="!!post.links?.length" class="mt-6 flex flex-row flex-wrap gap-2 font-medium">
        <NuxtLink v-for="link in post.links || []" class="border px-3 py-2 transition-colors border-gridline text-neutral-300 hover:text-white hover:border-neutral-600" :to="link.href" :target="link.href.startsWith('/') ? undefined : 'blank'" rel="noopener noreferrer">
          {{ link.label }}
        </NuxtLink>
      </footer>
    </article>
  </BlockSection>
</template>
