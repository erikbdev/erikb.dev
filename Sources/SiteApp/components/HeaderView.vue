<script lang="ts" setup>
import { ref } from 'vue';
import type { CodeLang } from '../types/codeLang';
import { allCodeLangs, getTitle } from '../types/codeLang';

defineProps<{
  modelValue: CodeLang;
}>();

const emit = defineEmits<{
  'update:modelValue': [value: CodeLang];
}>();

const visible = ref(false);

function selectLang(lang: CodeLang) {
  emit('update:modelValue', lang);
  visible.value = false;
}

// Close dropdown on escape
function handleKeydown(e: KeyboardEvent) {
  if (e.key === 'Escape') {
    visible.value = false;
  }
}
</script>

<template>
  <header>
    <div class="hgroup">
      <a href="/">
        <code class="logo">erikb.dev();</code>
      </a>

      <div class="code-selector-wrapper">
        <button
          :aria-pressed="visible ? 'true' : 'false'"
          @click="visible = !visible"
          @keydown="handleKeydown"
        >
          <code>&lt;/&gt;</code>
        </button>

        <ul v-if="visible" class="code-selector-menu">
          <li v-for="lang in allCodeLangs" :key="lang">
            <button
              :aria-selected="lang === modelValue"
              @click="selectLang(lang)"
            >
              <p>{{ getTitle(lang) }}</p>
            </button>
          </li>
        </ul>
      </div>
    </div>
  </header>
</template>

<style scoped>
header {
  border-top: 1px solid #303030;
}

.hgroup {
  display: flex;
  flex: none;
  justify-content: space-between;
  flex-direction: row;
  padding: 0.75rem 1.5rem;
  border-top: 1px solid #303030;
  border-bottom: 1px solid #303030;
  max-width: 40rem;
  margin: 0 auto;
}

a {
  text-decoration: none;
  color: inherit;
}

.logo {
  font-size: 0.84em;
  color: #aaa;
  font-weight: bold;
}

.code-selector-wrapper {
  position: relative;
}

button {
  font-weight: bold;
  font-size: 0.8em;
  background: unset;
  border: 1.16px solid #444;
  padding: 0.28rem 0.4rem;
  color: #aaa;
  cursor: pointer;
}

button:hover {
  background: #666;
}

button[aria-pressed='true'] {
  background: #8a8a8a;
  color: #080808;
}

.code-selector-menu {
  position: absolute;
  right: 0;
  list-style: none;
  padding: 0 0.4rem;
  margin-top: 0.25rem;
  margin: 0;
  background: #202019;
  border: 1px solid #303030;
  z-index: 10;
}

.code-selector-menu li {
  margin: 0.4rem 0;
}

.code-selector-menu button {
  all: unset;
  display: block;
  width: 100%;
  cursor: pointer;
  padding: 0.5rem;
  box-sizing: border-box;
  font-size: 1em;
}

.code-selector-menu button:hover {
  background: #3f3f3f;
}

.code-selector-menu button[aria-selected='true'] {
  background: #303030;
  box-shadow: inset 1px 1px #383838, inset -1px -1px #383838;
}

.code-selector-menu p {
  margin: 0;
  width: 100%;
}

code {
  font-family: 'CommitMono', monospace;
  font-feature-settings: 'ss03', 'ss04', 'ss05';
  line-height: 1;
}
</style>
