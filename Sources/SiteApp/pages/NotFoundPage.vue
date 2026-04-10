<script lang="ts" setup>
import { inject } from 'vue';
import type { CodeLang } from '../types/codeLang';
import HeaderView from '../components/HeaderView.vue';
import FooterView from '../components/FooterView.vue';
import SpacerDivider from '../components/SpacerDivider.vue';
import { useCodeLang } from '@/hooks/useCodeLang';

const codeLang = useCodeLang();
const notFoundDescription = 'The asset or page could not be found';
</script>

<template>
  <div class="flex flex-col h-full">
    <HeaderView />
    <SpacerDivider />
    <main class="grow flex flex-col">
      <section class="grow flex items-center justify-center">
        <div class="flex flex-col py-40 px-8 self-center w-full">
          <div class="container w-full p-6 border border-[#303030] max-w-[40rem] mx-auto">
            <div class="text-[0.75em] font-medium text-end pb-2 m-0">
              <pre>
                <a href="/not-found" class="text-[#777] no-underline">
                  <code class="hljs" :class="`language-${codeLang.id}`">
                    {{ codeLang.fileNameSlug("not-found") }}
                  </code>
                </a>
              </pre>
            </div>

            <div v-if="codeLang.id != 'md'" class="pt-4">
              <pre class="m-0 whitespace-pre-wrap"><code class="hljs" :class="`language-${codeLang.hljs}`">
                // 404 ERROR
                // {{ notFoundDescription }}

                <template v-if="codeLang.id === 'swift'">throw Error.notFound</template>
                <template v-else-if="codeLang.id === 'rs'">panic!("Not found");</template>
                <template v-else-if="codeLang.id === 'typescript'">throw new Error("Not found");</template></code></pre>
            </div>
            <div v-else class="pt-4">
              <h1 class="mb-0.5">
                <span class="text-[#808080] font-bold">#</span>
                Not Found
              </h1>
              <p class="text-[#d0d0d0] font-normal">{{ notFoundDescription }}</p>
            </div>
          </div>
        </div>
      </section>
    </main>
    <SpacerDivider />
    <FooterView />
  </div>
</template>

<style scoped>
.container {
  background-image: radial-gradient(#2a2a2a 1px, transparent 0);
  background-size: 12px 12px;
}
</style>
