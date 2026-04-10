<script lang="ts" setup>
import { ref } from 'vue';
import { allCodeLangs } from '@/types/codeLang';
import { useCodeLang } from '@/hooks/useCodeLang';

const codeLang = useCodeLang();
const visible = ref(false);

// Close dropdown on escape
function handleKeydown(e: KeyboardEvent) {
  if (e.key === 'Escape') {
    visible.value = false;
  }
}
</script>

<template>
  <header class="border-t border-[#303030]">
    <div class="auto-container flex flex-none justify-between flex-row px-6 py-3 border-t border-[#303030] border-b">
      <a class="no-underline text-inherit" href="/">
        <code class="text-[0.84em] text-[#aaa] font-bold">erikb.dev();</code>
      </a>

      <div class="relative">
        <button
          :aria-pressed="visible ? 'true' : 'false'"
          @click="visible = !visible"
          @keydown="handleKeydown"
          class="font-bold text-[0.8em] bg-transparent border border-[#444] px-[0.4rem] py-[0.28rem] text-[#aaa] cursor-pointer hover:bg-[#666] aria-pressed:bg-[#8a8a8a] aria-pressed:text-[#080808]"
        >
          <code>&lt;/&gt;</code>
        </button>

        <ul v-if="visible" class="absolute right-0 list-none px-[0.4rem] m-0 mt-1 bg-[#202019] border border-[#303030] z-10">
          <li v-for="lang in allCodeLangs" :key="lang.id" class="my-[0.4rem]">
            <button
              :aria-selected="codeLang.id == lang.id"
              @click="codeLang = lang"
              class="[all:unset] block w-full cursor-pointer p-2 box-border text-[1em] hover:bg-[#3f3f3f] aria-selected:bg-[#303030] aria-selected:shadow-[inset_1px_1px_#383838,inset_-1px_-1px_#383838]"
            >
              <p class="m-0 w-full">{{ lang.title }}</p>
            </button>
          </li>
        </ul>
      </div>
    </div>
  </header>
</template>
