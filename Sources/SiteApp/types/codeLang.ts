export type CodeLang = {
  id: string;
  title: string;
  hljs: string;
  fileNameSlug: (slug: string) => string;
}

export const allCodeLangs: CodeLang[] = [
   { 
    id: 'md',
    title: 'Markdown', 
    hljs: "markdown",
    fileNameSlug(slug) {
      return qualifiedId(slug)
        .join('-') + ".md"
    },
  },
  { 
    id: 'swift',
    title: 'Swift', 
    hljs: "swift",
    fileNameSlug(slug) {
      return qualifiedId(slug)
        .map(c => (c.charAt(0).toUpperCase() + c.slice(1)))
        .join('') + '.swift'
    },
  },
  { 
    id: 'rs',
    title: 'Rust', 
    hljs: "rust",
    fileNameSlug(slug) {
       return qualifiedId(slug)
        .join('-') + ".rs"
    }, 
  },
  { 
    id: 'ts',
    title: 'TypeScript', 
    hljs: "typescript",
    fileNameSlug(slug) {
      return qualifiedId(slug)
        .map((c, i) => (i === 0 ? c : c.charAt(0).toUpperCase() + c.slice(1)))
        .join('') + '.ts'
    },
  }
];

function qualifiedId(id: string): string[] {
    return id.split(/[-\s]+/)
      .map((c) => c.toLowerCase())
      .filter((c) => c.length > 0);
}