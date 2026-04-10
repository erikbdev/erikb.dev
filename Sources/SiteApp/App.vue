<script lang="ts" setup>
import { ref, provide, watch, nextTick, computed } from "vue";
import type { CodeLang } from "./types/codeLang";
import HomePage from "./pages/HomePage.vue";
import NotFoundPage from "./pages/NotFoundPage.vue";
import { useHLJS } from "./hooks/useHLJS";
import { useCodeLang } from "./hooks/useCodeLang";

const hljs = useHLJS();
const codeLang = useCodeLang();
const isHome = computed(() => window.location.pathname === "/");

watch(codeLang, async () => {
  await nextTick();
  hljs.highlightAll();
});
</script>

<template>
  <HomePage class="w-full mx-auto flex flex-col min-h-screen box-border" v-if="isHome" />
  <NotFoundPage class="w-full mx-auto flex flex-col min-h-screen box-border" v-else />
</template>
