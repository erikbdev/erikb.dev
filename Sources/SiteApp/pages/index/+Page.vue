<script lang="ts" setup>
import BlockSection from "@/components/BlockSection.vue";
import useCodeLang from "@/stores/useCodeLang";

const { codeLang } = useCodeLang()
</script>
<template>
  <BlockSection class="flex flex-col">
    <div class="w-full text-end text-xs text-neutral-500">
      <pre>
        <code>{{ codeLang.fileCase('user') }}</code>
      </pre>      
    </div>
    <h1>Welcome</h1>
    This page is:
    <ul>
      <li>Rendered to HTML.</li>
      <li>Interactive.</li>
    </ul>
  </BlockSection>
</template>
