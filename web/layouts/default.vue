<script setup lang="ts">
import PhCopyrightSVG from "@phosphor-icons/core/regular/copyright.svg?raw";
const showMenuDialog = ref(false);
const router = useRouter();
const route = useRoute();

const currentDate = new Date().toISOString();
const copyrightFooter = `${new Date().getUTCFullYear()} erikb.dev`;

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
  <header class="sticky w-full flex flex-col top-0 left-0 z-50" :class="{ 'bg-base/80 backdrop-blur-sm border-b border-gridline': !showMenuDialog, 'bg-base h-screen': showMenuDialog }">
    <BlockSection :divider="false" class="text-sm py-2! bg-transparent! text-neutral-800 border-gridline border-b"> TERM xterm-256color · TTY0 · connection opened </BlockSection>
    <BlockSection as="nav" :divider="showMenuDialog" class="sticky bg-transparent! h-(--header-height) flex flex-none justify-between items-center py-3! px-8!">
      <NuxtLink to="/" class="self-center" @click="closeMenu">
        <span class="text-white font-bold">erikb@dev:~<span class="text-terminal">$</span></span>
      </NuxtLink>

      <!-- TODO: use menu navigation -->
      <!-- <button class="font-bold border border-gridline py-1 px-2 cursor-pointer text-neutral-300 hover:text-white hover:border-neutral-500 transition-colors" :class="showMenuDialog ? 'bg-white! text-black! border-white!' : ''" @click.stop="showMenuDialog = !showMenuDialog">
        <span v-if="!showMenuDialog">menu {{ "\<m\>" }}</span>
        <span v-else>close {{ "\<q\>" }}</span>
      </button>  -->
    </BlockSection>

    <!-- TODO: show menu -->
    <!-- 
    <template v-if="showMenuDialog">
      <BlockSection class="w-full flex-1 flex flex-col">
        <p class="text-neutral-300 mb-6"><span class="text-primary">$</span> ls /</p>
        <ul class="grow">
          <li v-for="item in menuItems" class="text-5xl leading-none font-bold mb-2.5" :class="route.path === item.path ? 'text-terminal' : 'text-neutral-700 hover:text-white'">
            <NuxtLink :to="item.path" @click="closeMenu">
              <span><span class="text-neutral-800">~/</span>{{ item.name }}</span>
            </NuxtLink>
          </li>
        </ul>
      </BlockSection>
      <BlockSection as="footer" class="flex flex-col gap-1" :divider="false">
        <span class="text-neutral-500">© {{ copyrightFooter }}</span>
      </BlockSection>
    </template> 
    -->
  </header>
  <slot />
  <footer>
    <BlockSection :divider="false" class="px-8! py-0! h-(--header-height) text-neutral-600 content-center">
      <span class="size-[1em] inline-block mr-0.5 *:mt-0.5" v-html="PhCopyrightSVG"></span>
      <span> {{ copyrightFooter }}</span>
    </BlockSection>
    <BlockSection :divider="false" class="text-sm py-2! text-neutral-800 border-gridline border-t">connection closed.</BlockSection>
  </footer>
</template>
