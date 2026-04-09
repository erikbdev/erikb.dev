<script lang="ts" setup>
import { ref, provide, watch, nextTick, computed } from "vue";
import type { CodeLang } from "./types/codeLang";
import HomePage from "./pages/HomePage.vue";
import NotFoundPage from "./pages/NotFoundPage.vue";
import { useHLJS } from "./hooks/useHLJS";

const hljs = useHLJS();
const codeLang = ref<CodeLang>("markdown");

// Provide codeLang to all children
provide("codeLang", { value: codeLang });

const currentPath = computed(() => window.location.pathname);

const isHome = computed(() => currentPath.value === "/");

// Highlight code when language changes
watch(codeLang, async () => {
  await nextTick();
  hljs.highlightAll();
});
</script>

<template>
  <HomePage class="base-style" v-if="isHome" />
  <NotFoundPage class="base-style" v-else />
</template>

<style scoped>
.base-style {
  width: 100%;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  box-sizing: border-box;
}
</style>
