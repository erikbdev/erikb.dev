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
      default: true,
    },
  },
};
</script>
<template>
  <component
    :is="as"
    :class="[
      'relative bg-base border-border w-full',
      fill === true || fill === ''
        ? ''
        : [
            'md:border-x md:max-w-2xl mx-auto',
            {
              'px-6 py-6': fill !== 'inner',
            },
          ],
      divider
        ? 'mb-4 after:bg-base after:absolute after:h-4 after:-bottom-4 after:w-full after:md:w-2xl after:left-1/2 after:-translate-x-1/2 after:border after:border-border after:outline after:outline-border after:-outline-offset-1 big-divider'
        : 'mb-0 after:bg-base after:absolute after:h-0 after:bottom-0 after:w-full after:md:w-2xl after:left-1/2 after:-translate-x-1/2 after:border-b after:border-border compact-divider',
      // 'mt-0 before:bg-base before:absolute before:h-0 before:top-0 before:w-full  before:left-1/2 before:-translate-x-1/2 before:border-t before:border-border compact-divider',
    ]"
  >
    <slot></slot>
  </component>
</template>
<style>
.compact-divider::after {
  border-image: linear-gradient(to right, #303030, #303030) 1 / 1px / 0 100vw;
}

.big-divider::after {
  border-image: linear-gradient(to right, #303030, #303030) 1 / 1px / 0 100vw;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='8' height='8'%3E%3Cpath d='M0 8L8 0M-2 2L2-2M6 10L10 6' stroke='%23333' stroke-width='2' stroke-linecap='square'/%3E%3C/svg%3E");
  background-size: 6px 4px;
}
</style>
