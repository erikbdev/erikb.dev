<script setup lang="ts">
import BlockSection from "~/components/block-section.vue";

const props = defineProps({
  error: Object,
});

const statusCode = computed(() => props.error?.statusCode ?? 500);
const statusMessage = computed(() => props.error?.statusMessage || "The requested page or asset could not be found.");

const handleError = () => clearError({ redirect: "/" });
</script>
<template>
  <NuxtLayout>
    <BlockSection id="error">
      <header>
        <p class="text-sm inline-block text-neutral-50 mb-5"><span class="text-terminal">$</span> cat error.md</p>
      </header>

      <section>
        <h1 class="text-3xl font-bold mb-1 text-white">{{ statusCode }}</h1>
        <p class="text-neutral-300 mb-4">{{ statusMessage }}</p>
        <button @click="handleError" class="border border-gridline px-3 py-2 text-neutral-300 hover:text-white hover:border-neutral-600 transition-colors cursor-pointer">~/home</button>
      </section>
    </BlockSection>
  </NuxtLayout>
</template>
