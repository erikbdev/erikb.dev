import path, { dirname } from "node:path";
import { fileURLToPath } from "node:url";

import tailwindcss from "@tailwindcss/vite";
import { templateCompilerOptions } from "@tresjs/core";
import vue from "@vitejs/plugin-vue";
import markdown from "unplugin-vue-markdown/vite";
import vike from "vike/plugin";
import vueDevTools from "vite-plugin-vue-devtools";
import { defineConfig } from "vite-plus";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

export default defineConfig({
  staged: {
    "*": "vp check --fix",
  },
  root: "./web",
  plugins: [
    vue({
      ...templateCompilerOptions,
      include: [/\.vue$/, /\.md$/],
    }),
    markdown({
      markdownOptions: {
        breaks: true,
      },
      wrapperDiv: false,
    }),
    vike(),
    vueDevTools(),
    tailwindcss(),
  ],
  publicDir: "./../public",
  build: {
    outDir: "./../dist",
    emptyOutDir: true,
  },
  resolve: {
    tsconfigPaths: true,
    alias: {
      "@": path.resolve(__dirname, "./web"),
      "@components": path.resolve(__dirname, "./web/components"),
      "@stores": path.resolve(__dirname, "./web/stores"),
      "@assets": path.resolve(__dirname, "./web/assets"),
      "@posts": path.resolve(__dirname, "./web/posts"),
    },
  },
  server: {
    proxy: {
      "/api": "http://localhost:8080",
    },
  },
  fmt: {
    bracketSameLine: true,
    sortImports: true,
    printWidth: 320,
    singleAttributePerLine: false,
  },
  lint: {
    options: {
      typeAware: true,
      typeCheck: true,
    },
  },
});
