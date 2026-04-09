<script lang="ts" setup>
import { inject } from 'vue';
import type { CodeLang } from '../types/codeLang';
import HeaderView from '../components/HeaderView.vue';
import FooterView from '../components/FooterView.vue';
import SpacerDivider from '../components/SpacerDivider.vue';

const codeLang = inject<{ value: CodeLang }>('codeLang', { value: 'markdown' });

const notFoundDescription = 'The asset or page could not be found';
</script>

<template>
  <div style="display: flex; flex-direction: column; height: 100%">
    <HeaderView v-model="codeLang.value" />
    <SpacerDivider />
    <main style="flex-grow: 1; display: flex; flex-direction: column">
      <section style="flex-grow: 1; display: flex; align-items: center; justify-content: center">
        <div class="not-found-content">
          <div class="container">
            <div class="file-tag">
              <pre>
                <a href="/not-found">
                  <code class="hljs" :class="`language-${codeLang.value}`">
                    <template v-if="codeLang.value === 'swift'">NotFound.swift</template>
                    <template v-else-if="codeLang.value === 'typescript'">notFound.ts</template>
                    <template v-else-if="codeLang.value === 'rust'">not-found.rs</template>
                    <template v-else>not-found.md</template>
                  </code>
                </a>
              </pre>
            </div>

            <div v-if="codeLang.value !== 'markdown'" class="code-block">
              <pre><code class="hljs" :class="`language-${codeLang.value}`">// 404 ERROR
// {{ notFoundDescription }}

<template v-if="codeLang.value === 'swift'">throw Error.notFound</template>
<template v-else-if="codeLang.value === 'rust'">panic!("Not found");</template>
<template v-else-if="codeLang.value === 'typescript'">throw new Error("Not found");</template></code></pre>
            </div>
            <div v-else class="markdown-block">
              <h1 style="margin-bottom: 0.125rem">
                <span style="color: #808080; font-weight: 700">#</span>
                Not Found
              </h1>
              <p style="color: #d0d0d0; font-weight: normal">{{ notFoundDescription }}</p>
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
.not-found-content {
  display: flex;
  flex-direction: column;
  padding: 160px 32px;
  align-self: center;
  width: 100%;
}

.container {
  background-image: radial-gradient(#2a2a2a 1px, transparent 0);
  background-size: 12px 12px;
  width: 100%;
  padding: 1.5rem;
  border-top: 1px solid #303030;
  border-bottom: 1px solid #303030;
  border-left: 1px solid #303030;
  border-right: 1px solid #303030;
  max-width: 40rem;
  margin: 0 auto;
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
  padding-top: 1rem;
}

.code-block pre {
  margin: 0;
  white-space: pre-wrap;
}

.markdown-block {
  padding-top: 1rem;
}

code {
  font-family: 'CommitMono', monospace;
  font-feature-settings: 'ss03', 'ss04', 'ss05';
  line-height: 1;
}
</style>
