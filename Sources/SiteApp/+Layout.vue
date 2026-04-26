<script setup lang="ts">
import { ref } from 'vue';
import BlockSection from '@/components/BlockSection.vue';
import useCodeLang from '@/stores/useCodeLang.ts';
import HorizonWorld from '@/components/HorizonWorld.vue';

const showMenuDialog = ref(false);
</script>
<template>
  <main class="relative">
    <BlockSection as="nav" fill :divider="false" class="fixed! top-0 z-50 bg-base/90 flex flex-none justify-between py-3 px-4">
      <a href="/" class="text-sm self-center">
        <code class="text-white font-bold">erikb.dev();</code>
      </a>
      <button :class="`font-bold text-white text-sm border-[1.16px] border-solid border-neutral-700 py-1 px-2 cursor-pointer ${showMenuDialog ? 'bg-neutral-400 text-neutral-900' : ''}`" @click.stop="showMenuDialog = !showMenuDialog">
        <code>{{ '<menu>' }}</code>
      </button> 
    </BlockSection>
    
    <BlockSection fill class="h-screen">
      <HorizonWorld />
    </BlockSection> 
    <slot></slot>
    <BlockSection as="footer" :divider="false"></BlockSection>
  </main>
</template>
