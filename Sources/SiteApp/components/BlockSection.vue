<script lang="ts">
import type { PropType } from "vue";
export default {
  inheritAttrs: true,
  props: {
    as: {
      type: String,
      default: "section",
    },
    fill: {
      type: [String, Boolean] as PropType<"inner" | boolean | "">,
      default: false,
    },
    divider: {
      type: Boolean,
      default: true
    }
  },
};
</script>
<template>
  <component
    :is="as"
    :class="[
      'relative border-[#303030] w-full',
      divider ? 'mb-4 after:absolute after:h-4 after:-bottom-4 after:w-screen after:md:w-2xl after:left-1/2 after:-translate-x-1/2 after:border after:border-[#303030] after:outline after:outline-[#303030] after:-outline-offset-1 divider-lines' : 'border-b ',
      fill === true || fill === ''
        ? ''
        : [
            'md:border-x md:max-w-2xl mx-auto',
            {
              'px-6 py-6': fill !== 'inner',
            },
          ],
    ]"
  >
    <slot></slot>
  </component>
</template>
<style>
.divider-lines::after {
  border-image: linear-gradient(to right, #303030, #303030) 1 / 1px / 0 100vw;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='8' height='8'%3E%3Cpath d='M0 8L8 0M-2 2L2-2M6 10L10 6' stroke='%23333' stroke-width='2' stroke-linecap='square'/%3E%3C/svg%3E");
  background-size: 6px 4px;
}
</style>