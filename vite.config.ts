import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import vueDevTools from "vite-plugin-vue-devtools";
import tailwindcss from "@tailwindcss/vite";
import vike from 'vike/plugin';
import markdown from 'unplugin-vue-markdown/vite'
import { templateCompilerOptions } from '@tresjs/core'

export default defineConfig({
  root: "./Sources/SiteApp",
  plugins: [
    vue({ 
      ...templateCompilerOptions, 
      include: [/\.vue$/, /\.md$/]
    }), 
    markdown({
      markdownOptions: {
        breaks: true
      },
      wrapperDiv: false
    }),
    vike(), 
    vueDevTools(), 
    tailwindcss(),
  ],
  publicDir: "./../../public",
  build: {
    outDir: "./../../dist",
    emptyOutDir: true,
  },
  resolve: {
    tsconfigPaths: true,
  },
});
