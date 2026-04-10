import { ref } from "vue";
import { allCodeLangs, type CodeLang } from "@/types/codeLang";

const codeLang = ref<CodeLang>(allCodeLangs[0]!)

export function useCodeLang() {
  return codeLang;
}