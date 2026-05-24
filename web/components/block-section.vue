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
  slots: {
    header: [],
  },
};
</script>
<template>
  <component
    :is="as"
    :class="[
      // general
      'relative bg-base border-gridline w-full *:relative',
      // Top divider
      'before:-z-1 before:bg-inherit before:absolute before:w-screen before:top-[-0.8px] before:left-1/2 before:-translate-x-1/2 before:border-inherit before:border-t',
      divider ? 'before:-bottom-4' : 'before:bottom-0',

      // container
      fill === true || fill === ''
        ? ''
        : [
            'md:border-x md:max-w-2xl mx-auto',
            {
              'px-6 py-6': fill !== 'inner',
            },
          ],
      // bottom divider
      divider ? 'mb-4 after:absolute after:h-4 after:w-screen after:md:max-w-2xl after:-bottom-4 after:left-1/2 after:-translate-x-1/2 after:border-t after:border-inherit big-divider-bottom' : '',
    ]">
    <!-- <p><span class="text-yellow-500">$</span> <slot name="header" /></p> -->
    <!-- <slot name="header" /> -->
    <slot />
  </component>
</template>
<style>
.big-divider-bottom::after {
  box-shadow:
    -1px 0 0 0 inset var(--color-gridline),
    1px 0 0 0 inset var(--color-gridline);
  border-image: linear-gradient(to right, #303030, #303030) 1 / 1px 0 0 0 / 0 100vw 0 100vw;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='8' height='8'%3E%3Cpath d='M0 8L8 0M-2 2L2-2M6 10L10 6' stroke='%23333' stroke-width='2' stroke-linecap='square'/%3E%3C/svg%3E");
  background-size: 6px 4px;
}
</style>
