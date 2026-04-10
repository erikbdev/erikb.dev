import { defineConfig } from "vite-plus";
import vue from "@vitejs/plugin-vue";
import vueDevTools from "vite-plugin-vue-devtools";
import tailwindcss from '@tailwindcss/vite';
import path from "path";

export default defineConfig({
  root: "./Sources/SiteApp",
  plugins: [vue(), vueDevTools(), tailwindcss()],
  publicDir: "./../../public",
  build: {
    outDir: "./../../dist",
    emptyOutDir: true
  },
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./Sources/SiteApp"),
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
