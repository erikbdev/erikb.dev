import { defineConfig } from "vite-plus";
import vue from "@vitejs/plugin-vue";
import vueDevTools from "vite-plugin-vue-devtools";
import tailwindcss from "@tailwindcss/vite";
import vike from "vike/plugin";
import markdown from "unplugin-vue-markdown/vite";
import { templateCompilerOptions } from "@tresjs/core";
import path from "node:path";

export default defineConfig({
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
  },
  lint: {
    options: {
      typeAware: true,
      typeCheck: true,
    },
  },
});
