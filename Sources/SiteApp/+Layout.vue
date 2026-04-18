<script setup lang="ts">
import { ref } from 'vue';
import BlockSection from './components/BlockSection.vue';
import useCodeLang from './stores/useCodeLang.ts';
import Divider from './components/Divider.vue';

const showCodeLangDialog = ref(false);

const { codeLang, allCodeLangs } = useCodeLang()
</script>
<template>
  <BlockSection tag="header">
    <hgroup class="flex flex-none justify-between">
      <a href="/">
        <code class="text-[0.84em] text-white font-bold">erikb.dev();</code>
      </a>
      <div class="relative">
        <button :class="`font-bold text-xs border-[1.16px] border-solid border-neutral-700 py-1 px-2 cursor-pointer ${showCodeLangDialog ? 'bg-neutral-400 text-neutral-900' : ''}`" @click.stop="showCodeLangDialog = !showCodeLangDialog">
          <code>{{ '<lang/>' }}</code>
        </button> 
        <ul v-if="showCodeLangDialog" class="p-2 absolute right-0 flex flex-col gap-1 mt-1 border border-neutral-700 bg-[#1f1f1f]">
          <li v-for="lang in allCodeLangs" class="w-full h-full">
            <button :class="`w-full h-full p-2 cursor-pointer ${lang.id == codeLang.id ? 'bg-neutral-600 border border-neutral-700' : ''}`" @click.stop="codeLang = lang; showCodeLangDialog = false">{{ lang.label }}</button>
          </li>
        </ul>
      </div>
   </hgroup>   
  </BlockSection>
  <Divider />
  <slot></slot>
  <Divider />
  <BlockSection tag="footer">
  </BlockSection>
</template>
