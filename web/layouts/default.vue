<script setup lang="ts">
import PhCopyrightSVG from "@phosphor-icons/core/regular/copyright.svg?raw";

import BlockSection from "@/components/BlockSection.vue";
import HorizonWorld from "@/components/HorizonWorld.vue";

const showMenuDialog = ref(false);
const router = useRouter();
const route = useRoute();
const copyrightFooter = `${new Date().getUTCFullYear()} erikb.dev, All rights reserved.`;

useHead({
  titleTemplate(title) {
    return title ? `${title} | erikb.dev` : "erikb.dev";
  },
  meta: [
    { name: "charset", content: "utf-8" },
    { name: "viewport", content: "width=device-width, initial-scale=1.0, viewport-fit=cover" },
  ],
  htmlAttrs: {
    "data-theme": "dark",
  },
  bodyAttrs: {
    class: {
      "overflow-x-hidden": true,
      "overflow-y-hidden": showMenuDialog,
    },
  },
});

const menuItems = router.getRoutes().sort((r1, r2) => {
  const idx1 = "index" in r1.meta ? (r1.meta.index as number | undefined) : undefined;
  const idx2 = "index" in r2.meta ? (r2.meta.index as number | undefined) : undefined;
  if (idx1 !== undefined && idx2 !== undefined) {
    return idx1 - idx2;
  } else if (idx1 !== undefined) {
    return -1;
  } else if (idx2 !== undefined) {
    return 1;
  } else {
    return 0;
  }
});

function closeMenu() {
  showMenuDialog.value = false;
}
</script>
<template>
  <BlockSection as="header" fill :divider="false" class="fixed! top-0 z-50 border-t-0 bg-base/80! backdrop-blur-sm!">
    <nav class="flex flex-none justify-between py-3 px-6 text-sm md:max-w-2xl mx-auto md:border-border md:border-x">
      <NuxtLink to="/" class="self-center" @click="closeMenu">
        <code class="text-white font-bold">erikb.dev()</code>
      </NuxtLink>
      <button class="font-bold border-[1.16px] border-solid border-neutral-700 py-1 px-2 cursor-pointer" :class="showMenuDialog ? 'bg-neutral-100 text-black' : 'text-white'" @click.stop="showMenuDialog = !showMenuDialog">
        <code v-if="!showMenuDialog">{{ "\<menu\>" }}</code>
        <code v-else>{{ "close x" }}</code>
      </button>
    </nav>
  </BlockSection>
  <main class="relative pt-[100vh]">
    <BlockSection fill class="h-screen mt-[-100vh] fixed! border-0 -z-10" :divider="false">
      <TresCanvas class="bg-base">
        <HorizonWorld />
      </TresCanvas>
    </BlockSection>
    <slot />
  </main>
  <BlockSection as="footer" :divider="false" class="border-b-0">
    <code class="text-sm text-neutral-300"><span class="size-[1em] inline-block mr-0.5" v-html="PhCopyrightSVG"></span>{{ copyrightFooter }}</code>
  </BlockSection>

  <div v-if="showMenuDialog" class="fixed top-0 left-0 pt-13 bg-base w-full h-screen overscroll-y-auto">
    <BlockSection :divider="false" class="w-full h-full flex flex-col">
      <ul class="grow">
        <li v-for="item in menuItems" class="text-[3rem] leading-none font-bold mb-2.5" :class="{ 'text-primary': route.path === item.path }">
          <NuxtLink :to="item.path" @click="closeMenu">{{ item.name }}</NuxtLink>
        </li>
      </ul>
      <footer>
        <code class="text-sm text-neutral-300"><span class="size-[1em] inline-block mr-0.5" v-html="PhCopyrightSVG"></span>{{ copyrightFooter }}</code>
      </footer>
    </BlockSection>
  </div>
</template>
