<script setup lang="ts">
const props = defineProps({
  tag: {
    type: String,
  },
  fillInner: {
    type: Boolean
  }
});
</script>
<template>
  <component :is="props.tag || 'div'" class="border-b border-[#303030]">
    <div :class="`border-x border-[#303030] md:max-w-2xl mx-auto ${props.fillInner ? '' : 'px-6 py-3'}`">
      <slot></slot>
    </div>
  </component>
</template>
