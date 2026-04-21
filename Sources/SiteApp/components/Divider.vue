<script setup lang="ts">
import BlockSection from './BlockSection.vue';
</script>
<template>
  <BlockSection as="div" fill="inner">
    <span class="h-3 block divider-background"></span>
  </BlockSection>
</template>
<style lang="css">
.divider-background {
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='8' height='8'%3E%3Cpath d='M0 8L8 0M-2 2L2-2M6 10L10 6' stroke='%23333' stroke-width='1.5' stroke-linecap='square'/%3E%3C/svg%3E");
  background-size: 5px 5px;
}
</style>