import { ref } from "vue";

export type CodeLangID = "md" | "swift" | "ts" | "rs";

export type CodeLang = CodeLangType<CodeLangID>;

type CodeLangType<K extends CodeLangID> = {
  id: K;
  label: string;
  fileCase(id: string): string;
};

type AllCodeLangs = {
  [K in CodeLangID]: CodeLangType<K>;
};

const allCodeLangs: AllCodeLangs = {
  md: {
    id: "md",
    label: "Markdown",
    fileCase(id) {
      return "";
    },
  },
  swift: {
    id: "swift",
    label: "Swift",
    fileCase(id) {
      return "";
    },
  },
  ts: {
    id: "ts",
    label: "TypeScript",
    fileCase(id) {
      return "";
    },
  },
  rs: {
    id: "rs",
    label: "Rust",
    fileCase(id) {
      return "";
    },
  },
};

const codeLang = ref<CodeLang>(allCodeLangs.md);

export default function useCodeLang() {
  return {
    codeLang,
    allCodeLangs
  }
}
