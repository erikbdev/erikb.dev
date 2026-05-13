<script setup lang="ts">
import PhCopyrightSVG from "@phosphor-icons/core/regular/copyright.svg?raw";

const showMenuDialog = ref(false);
const router = useRouter();
const route = useRoute();
const copyrightFooter = `${new Date().getUTCFullYear()} erikb.dev, All rights reserved.`;

useHead({
  titleTemplate(title) {
    return (title ? `${title} | ` : "") + "erikb.dev";
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
  link: [
    { rel: "icon", type: "image/png", sizes: "16x16", href: "/favicon-16x16.png" },
    { rel: "icon", type: "image/png", sizes: "32x32", href: "/favicon-32x32.png" },
    { rel: "icon", type: "image/png", sizes: "96x96", href: "/favicon-96x96.png" },
    { rel: "icon", type: "image/png", sizes: "128x128", href: "/favicon-128x128.png" },
  ],
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
  <BlockSection as="header" fill :divider="false" class="fixed! flex flex-col top-0 z-50 border-t-0!" :class="{ 'bg-base/80! backdrop-blur-sm!': !showMenuDialog, 'h-full': showMenuDialog }">
    <nav class="w-full h-(--header-height) flex flex-none justify-between py-3 px-6 text-sm md:max-w-2xl mx-auto md:border-border md:border-x">
      <NuxtLink to="/" class="self-center" @click="closeMenu">
        <code class="text-white font-bold">erikb.dev()</code>
      </NuxtLink>
      <button class="font-bold border-[1.16px] border-solid border-neutral-700 py-1 px-2 cursor-pointer" :class="showMenuDialog ? 'bg-neutral-100 text-black' : 'text-white'" @click.stop="showMenuDialog = !showMenuDialog">
        <code v-if="!showMenuDialog">{{ "\<menu\>" }}</code>
        <code v-else>{{ "close x" }}</code>
      </button>
    </nav>

    <template v-if="showMenuDialog">
      <BlockSection :divider="false" class="w-full flex-1 flex flex-col">
        <ul class="grow">
          <li v-for="item in menuItems" class="text-[3rem] leading-none font-bold mb-2.5 *:hover:underline *:hover:decoration-2 *:hover:underline-offset-3" :class="{ 'text-primary': route.path === item.path }">
            <NuxtLink :to="item.path" @click="closeMenu">{{ item.name }}</NuxtLink>
          </li>
        </ul>
      </BlockSection>
      <BlockSection as="footer" :divider="false" class="border-b-0">
        <code class="text-sm text-neutral-300"><span class="size-[1em] inline-block mr-0.5 *:mt-0.5" v-html="PhCopyrightSVG"></span>{{ copyrightFooter }}</code>
      </BlockSection>
    </template>
  </BlockSection>
  <main class="relative">
    <BlockSection fill class="h-screen border-0" :divider="false">
      <TresCanvas class="bg-inherit" shadows window-size :tone-mapping="0" :tone-mapping-exposure="0.0005">
        <InteractiveRoom />
      </TresCanvas>
    </BlockSection>
    <slot />
  </main>
  <BlockSection as="footer" :divider="false" class="border-b-0">
    <code class="text-sm text-neutral-300"><span class="size-[1em] inline-block mr-0.5 *:mt-0.5" v-html="PhCopyrightSVG"></span>{{ copyrightFooter }}</code>
  </BlockSection>
</template>
