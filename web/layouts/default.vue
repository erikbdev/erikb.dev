<script setup lang="ts">
import PhCopyrightSVG from "@phosphor-icons/core/regular/copyright.svg?raw";
const showMenuDialog = ref(false);
const router = useRouter();
const route = useRoute();

const currentDate = computed(() => new Date().toISOString());
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
      "mt-(--header-height)": true,
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
  <header class="fixed w-full flex flex-col top-0 left-0 z-50" :class="{ 'bg-base/80 backdrop-blur-sm border-b border-gridline': !showMenuDialog, 'bg-base h-full': showMenuDialog }">
    <BlockSection as="nav" :divider="showMenuDialog" class="bg-transparent! h-(--header-height) flex flex-none justify-between items-center py-3! px-6! text-sm">
      <NuxtLink to="/" class="self-center" @click="closeMenu">
        <span class="text-white font-bold">erikb@dev:~<span class="text-terminal">$</span></span>
      </NuxtLink>

      <div class="hidden sm:flex items-center gap-2 text-[10px] text-neutral-700 tracking-wide">
        <span>TTY0</span>
        <span class="text-neutral-800">·</span>
        <span>{{ currentDate }}</span>
      </div>

      <!-- 
      <button class="font-bold border border-gridline py-1 px-2 cursor-pointer text-neutral-500 hover:text-white hover:border-neutral-500 transition-colors" :class="showMenuDialog ? 'bg-white! text-black! border-white!' : ''" @click.stop="showMenuDialog = !showMenuDialog">
        <span v-if="!showMenuDialog">ls</span>
        <span v-else>close {{ "\<q\>" }}</span>
      </button> 
      -->
    </BlockSection>
    <template v-if="showMenuDialog">
      <BlockSection class="w-full flex-1 flex flex-col">
        <p class="text-xs text-neutral-700 mb-6">$ ls ~/</p>
        <ul class="grow">
          <li v-for="item in menuItems" class="text-[3rem] leading-none font-bold mb-2.5" :class="route.path === item.path ? 'text-terminal' : 'text-neutral-700 hover:text-white'">
            <NuxtLink :to="item.path">
              <span><span class="text-neutral-800">~/</span>{{ item.name }}</span>
            </NuxtLink>
          </li>
        </ul>
      </BlockSection>
      <BlockSection as="footer" :divider="false">
        <div class="flex flex-col gap-1">
          <span class="text-xs text-neutral-700">© {{ copyrightFooter }}</span>
          <span class="text-[10px] text-neutral-800">TERM xterm-256color · TTY0 · connection open</span>
        </div>
      </BlockSection>
    </template>
  </header>
  <slot />
  <BlockSection as="footer" :divider="false">
    <div class="flex flex-col gap-1">
      <span class="text-sm text-neutral-500">
        <span class="size-[1em] inline-block mr-0.5 *:mt-0.5" v-html="PhCopyrightSVG"></span>
        <span> {{ copyrightFooter }}</span>
      </span>
      <span class="text-sm text-neutral-800">connection closed.</span>
    </div>
  </BlockSection>
</template>
