import hljs from "highlight.js";
import "highlight.js/styles/atom-one-dark.css";
import "highlight.js/lib/languages/swift";
import "highlight.js/lib/languages/rust";
import "highlight.js/lib/languages/typescript";
import "highlight.js/lib/languages/markdown";


export function useHLJS() {
  return hljs;
}