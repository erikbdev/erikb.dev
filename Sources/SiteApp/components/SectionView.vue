<script lang="ts" setup>
import type { CodeLang } from '../types/codeLang';
import { fileNameSlug } from '../types/codeLang';

defineProps<{
  id: string;
  selected: CodeLang;
}>();

defineSlots<{
  header(props: { lang: CodeLang }): any;
  content(): any;
}>();
</script>

<template>
  <section :id="id">
    <div class="auto-container">
      <header class="section-header">
        <hgroup class="section-hgroup">
          <pre class="file-tag">
            <a :href="`#${id}`">
              <code class="hljs" :class="`language-${selected}`">
                {{ fileNameSlug(id, selected) }}
              </code>
            </a>
          </pre>

          <div v-if="selected !== 'markdown'" class="code-block">
            <pre><code class="hljs" :class="`language-${selected}`"><slot name="header" :lang="selected" /></code></pre>
          </div>
          <div v-else class="markdown-block">
            <slot name="header" :lang="selected" />
          </div>
        </hgroup>
      </header>

      <slot name="content" />
    </div>
  </section>
</template>

<style scoped>
section {
  border-top: 1px solid #303030;
}

.auto-container {
  max-width: 40rem;
  margin: 0 auto;
}

.section-header {
  padding: 1.5rem;
}

.section-hgroup {
  margin: 0;
}

.file-tag {
  font-size: 0.75em;
  font-weight: 500;
  text-align: end;
  padding-bottom: 0.5rem;
  margin: 0;
}

.file-tag a {
  color: #777;
  text-decoration: none;
}

.code-block {
  padding-bottom: 0.75rem;
}

.code-block pre {
  white-space: pre-wrap;
  margin: 0;
}

.markdown-block {
  padding-bottom: 0.75rem;
}

code {
  font-family: 'CommitMono', monospace;
  font-feature-settings: 'ss03', 'ss04', 'ss05';
  line-height: 1;
}
</style>
