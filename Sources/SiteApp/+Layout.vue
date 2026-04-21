<script setup lang="ts">
import { ref } from 'vue';
import BlockSection from './components/BlockSection.vue';
import useCodeLang from './stores/useCodeLang.ts';
import Divider from './components/Divider.vue';
import HorizonWorld from './components/HorizonWorld.vue';

const showCodeLangDialog = ref(false);

const { codeLang, allCodeLangs } = useCodeLang()
</script>
<template>
  <main class="relative">
    <!-- Navigation -->
    <BlockSection as="nav" fill class="fixed! top-0 z-50 bg-base/90">
      <div class="flex flex-none justify-between md:max-w-2xl mx-auto py-2 px-3">
        <a href="/">
          <code class="text-[0.84em] text-white font-bold">erikb.dev();</code>
        </a>
        <div class="relative">
          <button :class="`font-bold text-white text-xs border-[1.16px] border-solid border-neutral-700 py-1 px-2 cursor-pointer ${showCodeLangDialog ? 'bg-neutral-400 text-neutral-900' : ''}`" @click.stop="showCodeLangDialog = !showCodeLangDialog">
            <code>{{ '<menu>' }}</code>
          </button> 
          <ul v-if="showCodeLangDialog" class="z-100 p-2 absolute right-0 flex flex-col gap-1 mt-1 border border-neutral-700 bg-[#1f1f1f]">
            <li v-for="lang in allCodeLangs" class="w-full h-full">
              <button :class="`w-full h-full p-2 cursor-pointer ${lang.id == codeLang.id ? 'bg-neutral-600 border border-neutral-700' : ''}`" @click.stop="codeLang = lang; showCodeLangDialog = false">{{ lang.label }}</button>
            </li>
          </ul>
        </div>
      </div>   
    </BlockSection>
    <BlockSection fill class="w-screen h-screen">
      <HorizonWorld />
    </BlockSection>
    <Divider />
    <slot></slot>
    <Divider />
    <BlockSection as="footer"></BlockSection>
  </main>
</template>
