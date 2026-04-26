<script lang="ts" setup>
import BlockSection from "@/components/BlockSection.vue";
import useCodeLang from "@/stores/useCodeLang";

const { codeLang } = useCodeLang()
</script>
<template>
  <BlockSection>
    <div class="w-full text-sm text-end text-neutral-500">
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
