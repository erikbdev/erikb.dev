import type { Config } from "vike/types";
import vikeVue from "vike-vue/config";

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
