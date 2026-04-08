import { defineConfig } from "vite-plus";
import vue from "@vitejs/plugin-vue";
import vueDevTools from "vite-plugin-vue-devtools";

export default defineConfig({
  root: "./Sources/SiteApp",
  plugins: [vue(), vueDevTools()],
  publicDir: "./../../public",
  build: {
    outDir: "./../../dist",
  },
  resolve: {
    alias: {
      "@": ".",
    }
  },
  fmt: {},
  lint: { 
    options: { 
      typeAware: true, 
      typeCheck: true 
    } 
  },
});
