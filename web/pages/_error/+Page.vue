<script setup lang="ts">
import BlockSection from "@/components/BlockSection.vue";
import { useCodeLang } from "@/stores/use-codelang";

const { codeLang } = useCodeLang()
</script>
<template>
  <BlockSection class="flex flex-col size-128 bg-dotted">
    <a id="not-found" href="#not-found" class="self-end text-sm text-neutral-500">
      <code>{{ codeLang.fileCase('not-found') }}</code>
    </a>
    <div class="self-center content-center h-full">
      <p v-if="codeLang.id == 'md'" class="text-3xl font-bold mb-2">
        <span class="text-neutral-400">#</span> Not Found
      </p>
      <p>The asset or page could not be found</p>
    </div>
  </BlockSection>
</template>
<style lang="css">
.bg-dotted {
  background-image: radial-gradient(#2A2A2A 1px, transparent 0);
  background-size: 12px 12px;
}
</style>