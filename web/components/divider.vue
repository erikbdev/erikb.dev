<template>
  <BlockSection as="hr"> </BlockSection>
</template>
<style>
.big-divider-bottom::after {
  box-shadow:
    -1px 0 0 0 inset var(--color-gridline),
    1px 0 0 0 inset var(--color-gridline);
  border-image: linear-gradient(to right, var(--color-gridline), var(--color-gridline)) 1 / 1px 0 0 0 / 0 100vw 0 100vw;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='8' height='8'%3E%3Cpath d='M0 8L8 0M-2 2L2-2M6 10L10 6' stroke='%231c1c1c' stroke-width='2' stroke-linecap='square'/%3E%3C/svg%3E");
  background-size: 6px 4px;
}
</style>
