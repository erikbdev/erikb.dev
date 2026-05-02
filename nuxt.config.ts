import tailwindcss from "@tailwindcss/vite";

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: "2025-07-15",
  devtools: { enabled: true },
  modules: ["@tresjs/nuxt", "@nuxt/content"],
  srcDir: "web",
  css: ["~/assets/css/main.css"],
  content: {
    build: {
      markdown: {
        highlight: {
          theme: "github-dark",
          langs: ["swift", "rust", "typescript", "markdown"],
        },
      },
    },
  },
  vite: {
    // root: "./web",
    plugins: [tailwindcss()],
    // publicDir: "./../public",
    build: {
      // outDir: "./../dist",
      emptyOutDir: true,
    },
    server: {
      proxy: {
        "/api": "http://localhost:8080",
      },
    },
  },
});
