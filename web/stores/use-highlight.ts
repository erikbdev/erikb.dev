import hljs from "highlight.js/lib/core";
import markdown from "highlight.js/lib/languages/markdown";
import rust from "highlight.js/lib/languages/rust";
import swift from "highlight.js/lib/languages/swift";
import typescript from "highlight.js/lib/languages/typescript";

export function useHighlight() {
  return {
    register() {
      hljs.registerLanguage("swift", swift);
      hljs.registerLanguage("markdown", markdown);
      hljs.registerLanguage("rust", rust);
      hljs.registerLanguage("typescript", typescript);
    },
    highlightAll() {
      hljs.highlightAll();
    },
  };
}
