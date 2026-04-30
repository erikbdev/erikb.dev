<script setup lang="ts">
import { ref } from 'vue';
import BlockSection from '@/components/BlockSection.vue';
import HorizonWorld from '@/components/HorizonWorld.vue';

import { PhCopyright } from '@phosphor-icons/vue';

const showMenuDialog = ref(false);
</script>
<template>
    <BlockSection as="header" fill :divider="false" class="fixed! top-0 z-50 bg-base/80 backdrop-blur-sm">
      <nav class="flex flex-none justify-between py-3 px-6 md:max-w-2xl mx-auto md:border-border md:border-x">
        <a href="/" class="text-sm self-center">
          <code class="text-white font-bold">erikb.dev()</code>
        </a>
        <button class="font-bold text-sm border-[1.16px] border-solid border-neutral-700 py-1 px-2 cursor-pointer" :class="showMenuDialog ? 'bg-neutral-100 text-black' : 'text-white'" @click.stop="showMenuDialog = !showMenuDialog">
          <code>{{ '<menu>' }}</code>
        </button> 
      </nav>
    </BlockSection>
    <main>
      <BlockSection fill class="h-screen">
        <HorizonWorld />
      </BlockSection> 
      <slot></slot>
    </main>
    <BlockSection as="footer" :divider="false">
      <code class="text-sm"><PhCopyright size="1em" class="inline-block mb-0.5 mr-0.5" />{{ new Date().getFullYear() }} erikb.dev, All Rights Reserved.</code>
    </BlockSection>
</template>
