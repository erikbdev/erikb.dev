<script lang="ts">
import type { PropType } from "vue";
export default {
  props: {
    tag: {
      type: String,
      default: "div",
    },
    fill: {
      type: [String, Boolean] as PropType<"inner" | boolean | "">,
      default: false,
    },
  },
};
</script>
<template>
  <component
    :is="$props.tag || 'div'"
    :class="[
      'relative border-[#303030]',
      'after:absolute after:bottom-0 after:left-1/2 after:w-screen after:-translate-x-1/2 after:h-px after:bg-[#303030] ',
      $props.fill === true || $props.fill === ''
        ? ''
        : [
            'md:border-x md:max-w-2xl mx-auto',
            {
              'px-6 py-3': $props.fill !== 'inner',
            },
          ],
    ]"
  >
    <slot></slot>
  </component>
</template>
