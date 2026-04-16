<script setup lang="ts">
import useCodeLang from './stores/useCodeLang.ts';

const codeLang = useCodeLang()
</script>
<template>
  <header class="border-t border-solid border-[#303030]">
    <hgroup class="flex flex-none justify-between flex-row px-3 py-6 md:max-w-2xl mx-auto border-x border-solid md:border-x-[#303030]">
      <a href="/">
        <code class="text-[0.84em] text-white font-bold">erikb.dev();</code>
      </a>
      <div>
        <button class="font-bold text-sm border-[1.16px] border-solid px-1 py-2 text-white cursor-pointer">
          <code></\></code>
        </button>
      </div>
    </hgroup>
  </header>
  <main>
    <!-- <slot></slot> -->
  </main>
  <footer></footer>
</template>
