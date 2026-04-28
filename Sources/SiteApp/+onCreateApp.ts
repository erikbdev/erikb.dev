import type { PageContext } from "vike/types";
import hljs from 'highlight.js/lib/core';
import swift from 'highlight.js/lib/languages/swift';
import markdown from 'highlight.js/lib/languages/markdown';
import rust from 'highlight.js/lib/languages/rust';
import typescript from 'highlight.js/lib/languages/typescript';

import "@/assets/global.css";

export function onCreateApp(pageContext: PageContext) {
  // const app = pageContext.app!;
  hljs.registerLanguage('swift', swift)
  hljs.registerLanguage('markdown', markdown)
  hljs.registerLanguage('rust', rust)
  hljs.registerLanguage('typescript', typescript)
}
