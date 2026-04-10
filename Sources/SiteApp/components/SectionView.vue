<script lang="ts" setup>
import { useCodeLang } from '@/hooks/useCodeLang';
import type { CodeLang } from '../types/codeLang';

defineProps<{ id: string; }>();

defineSlots<{
  header(props: { lang: CodeLang }): any;
  content(): any;
}>();

const codeLang = useCodeLang();
</script>

<template>
  <section :id="id" class="border-t border-[#303030]">
    <div class="auto-container">
      <header class="p-6">
        <hgroup class="m-0">
          <pre class="text-[0.75em] font-medium text-end pb-2 m-0">
            <a :href="`#${id}`" class="text-[#777] no-underline">
              <code class="hljs" :class="`language-${codeLang.hljs}`">
                {{ codeLang.fileNameSlug(id) }}
              </code>
            </a>
          </pre>

          <div v-if="codeLang.id != 'md'" class="pb-3">
            <pre class="whitespace-pre-wrap m-0"><code class="hljs" :class="`language-${codeLang.hljs}`"><slot name="header" :lang="codeLang" /></code></pre>
          </div>
          <div v-else class="pb-3">
            <slot name="header" :lang="codeLang" />
          </div>
        </hgroup>
      </header>

      <slot name="content" />
    </div>
  </section>
</template>
