import { defineConfig } from "vite-plus";

export default defineConfig({
  root: "./Sources/SiteApp",
  base: "./../..",
  publicDir: "./../../public",
  build: {
    outDir: "./../../dist",
  },
  fmt: {},
  lint: { 
    options: { 
      typeAware: true, 
      typeCheck: true 
    } 
  },
});
