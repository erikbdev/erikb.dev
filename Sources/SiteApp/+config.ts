import type { Config } from "vike/types";
import vikeVue from "vike-vue/config";

export default {
  clientRouting: true,
  prerender: true,
  ssr: false,
  extends: [vikeVue],
  htmlAttributes: { 
    "data-theme": "dark"
   }
} satisfies Config;
