import type { PageContext } from "vike/types";
import "@/assets/global.css";
import { useHighlight } from "./stores/use-highlight";

export function onCreateApp(_pageContext: PageContext) {
  // const app = pageContext.app!;
  const highlight = useHighlight();
  highlight.register();
}
