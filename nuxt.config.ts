import tailwindcss from "@tailwindcss/vite";

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: "2025-07-15",
  devtools: { enabled: true },
  modules: ["@tresjs/nuxt", "@nuxtjs/mdc"],
  srcDir: "web",
  css: ["~/assets/css/main.css"],
  // typescript: {
  //   strict: true,
  //   typeCheck: true,
  // },
  mdc: {
    highlight: {
      theme: "github-dark",
      langs: ["swift", "ruby", "typescript", "markdown"],
    },
  },
  nitro: {
    static: true,
    prerender: {
      crawlLinks: true,
    },
  },
  vite: {
    plugins: [tailwindcss()],
    server: {
      proxy: {
        "/api": "http://localhost:8080",
      },
    },
    optimizeDeps: {
      include: ["three", "@phosphor-icons/vue"],
    },
  },
});
