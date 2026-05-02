import vikeVue from "vike-vue/config";
import type { Config } from "vike/types";

export default {
  clientRouting: true,
  prerender: true,
  ssr: true,
  extends: [vikeVue],
  htmlAttributes: {
    "data-theme": "dark",
  },
  bodyAttributes: {
    class: "overflow-x-hidden",
  },
} satisfies Config;
