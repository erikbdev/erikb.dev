<script setup lang="ts">
import { PhCopyright } from "@phosphor-icons/vue";
import { usePageContext } from "vike-vue/usePageContext";
import { ref, watch } from "vue";

import BlockSection from "@/components/BlockSection.vue";
import HorizonWorld from "@/components/HorizonWorld.vue";

const showMenuDialog = ref(false);

const menuItems = [
  {
    name: "Home",
    href: "/",
  },
  {
    name: "Showcase",
    href: "/showcase",
  },
];

watch(
  () => showMenuDialog.value,
  (newValue) => {
    if (newValue) {
      document.body.classList.add("overflow-y-hidden");
    } else {
      document.body.classList.remove("overflow-y-hidden");
    }
  },
);
</script>
<template>
  <BlockSection as="header" fill :divider="false" class="fixed! top-0 z-50 border-t-0 bg-base/80! backdrop-blur-sm!">
    <nav class="flex flex-none justify-between py-3 px-6 md:max-w-2xl mx-auto md:border-border md:border-x">
      <a href="/" class="text-sm self-center">
        <code class="text-white font-bold">erikb.dev()</code>
      </a>
      <button class="font-bold text-sm border-[1.16px] border-solid border-neutral-700 py-1 px-2 cursor-pointer" :class="showMenuDialog ? 'bg-neutral-100 text-black' : 'text-white'" @click.stop="showMenuDialog = !showMenuDialog">
        <code>{{ "\<menu\>" }}</code>
      </button>
    </nav>
  </BlockSection>
  <main class="relative pt-[100vh]">
    <BlockSection fill class="h-screen mt-[-100vh] fixed! border-0 -z-10" :divider="false">
      <HorizonWorld />
    </BlockSection>
    <slot></slot>
  </main>
  <BlockSection as="footer" :divider="false" class="border-b-0">
    <code class="text-sm"><PhCopyright size="1em" class="inline-block mb-0.5 mr-0.5" />{{ new Date().getFullYear() }} erikb.dev, All Rights Reserved.</code>
  </BlockSection>

  <div v-if="showMenuDialog" class="fixed top-0 left-0 pt-13 bg-base w-full h-screen overscroll-y-auto">
    <BlockSection :divider="false" class="w-full h-full flex flex-col">
      <ul class="grow">
        <li v-for="item in menuItems">
          <p class="text-3xl font-semibold mb-2">{{ item.name }}</p>
        </li>
      </ul>
      <code class="text-sm"><PhCopyright size="1em" class="inline-block mb-0.5 mr-0.5" />{{ new Date().getFullYear() }} erikb.dev, All Rights Reserved.</code>
    </BlockSection>
  </div>
</template>
