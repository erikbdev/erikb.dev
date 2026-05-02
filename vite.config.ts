import { defineConfig } from "vite-plus";

export default defineConfig({
  staged: {
    "*": "vp check --fix",
  },
  fmt: {
    bracketSameLine: true,
    sortImports: true,
    printWidth: 320,
    singleAttributePerLine: false,
    ignorePatterns: ["dependencies/**"],
  },
  lint: {
    options: {
      typeAware: true,
      typeCheck: true,
    },
  },
});
