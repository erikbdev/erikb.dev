<script lang="ts">
import type { PropType } from 'vue';
export default {
  props: {
    tag: {
      type: String,
      default: "div"
    },
    fill: {
      type: String as PropType<"inner" | boolean | "">,
      default: false
    }
  }
}
</script>
<template>
  <component :is="$props.tag || 'div'" class="border-b border-[#303030]">
    <div 
      :class="[
        'border-x border-[#303030]',
        ($props.fill === true || $props.fill === '') ? '' : [
          'md:max-w-2xl mx-auto',
          {
            'px-6 py-3': $props.fill !== 'inner',
          }
        ]
      ]">
      <slot></slot>
    </div>
  </component>
</template>
