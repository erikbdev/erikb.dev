<script lang="ts">
import type { PropType } from "vue";
export default {
  props: {
    tag: {
      type: String,
      default: "section",
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
      'after:absolute after:border-b after:w-screen after:left-1/2 after:bottom-0 after:-translate-x-1/2 after:border-[#303030]',
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
