export type CodeLang = 'markdown' | 'swift' | 'rust' | 'typescript';

export const codeLangInfo: Record<CodeLang, { title: string; ext: string; hasSemiColon: boolean }> = {
  markdown: { title: 'Markdown', ext: 'md', hasSemiColon: false },
  swift: { title: 'Swift', ext: 'swift', hasSemiColon: false },
  rust: { title: 'Rust', ext: 'rs', hasSemiColon: true },
  typescript: { title: 'TypeScript', ext: 'ts', hasSemiColon: true }
};

export function getTitle(lang: CodeLang): string {
  return codeLangInfo[lang].title;
}

export function getExt(lang: CodeLang): string {
  // return codeLangInfo[lang].ext;
  return codeLangInfo[lang]?.ext ?? lang
}

export function hasSemiColon(lang: CodeLang): boolean {
  return codeLangInfo[lang].hasSemiColon;
}

export function fileNameSlug(id: string, lang: CodeLang): string {
  const components = id
    .split(/[-\s]+/)
    .map((c) => c.toLowerCase())
    .filter((c) => c.length > 0);

  let fileName: string;

  if (lang === 'markdown' || lang === 'rust') {
    fileName = components.join('-');
  } else if (lang === 'swift') {
    fileName = components.map((c) => c.charAt(0).toUpperCase() + c.slice(1)).join('');
  } else {
    // typescript
    fileName = components
      .map((c, i) => (i === 0 ? c : c.charAt(0).toUpperCase() + c.slice(1)))
      .join('');
  }

  return `${fileName}.${getExt(lang)}`;
}

export const allCodeLangs: CodeLang[] = ['markdown', 'swift', 'rust', 'typescript'];
