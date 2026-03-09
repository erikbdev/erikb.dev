// import ConcurrencyExtras
// import Dependencies
// @_spi(Render) import HTML
// import Hummingbird
// import PublicAssets
// import Routes
// import Vue

// public struct PageLayout<Content: Page & Sendable>: HTMLDocument, Sendable {
//   @Dependency(\.publicAssets) private var assets
//   @Dependency(\.currentRoute) private var currentRoute
//   @Dependency(\.siteRouter) private var siteRouter

//   let metadata: Metadata
//   let page: Content

//   public init(
//     metadata: Metadata,
//     @HTMLBuilder content: () -> Content
//   ) {
//     self.metadata = metadata
//     self.page = content()
//   }

//   public var head: some AsyncHTML & Sendable {
//     tag("title") { page.title }
//     meta(.charset(.utf8))
//     meta(.name("viewport"), .content("width=device-width, initial-scale=1.0, viewport-fit=cover"))
//     meta(.name("robots"), .content("index, follow"))
//     BaseStyles()
//     FavIcons()

//     if let title = metadata.title {
//       meta(.name(title))
//       meta(.property("og:title"), .content(title))
//       meta(.property("twitter:title"), .content(title))
//     }

//     if let description = metadata.description {
//       meta(.property("description"), .content(description))
//       meta(.property("og:description"), .content(metadata.description))
//       meta(.property("twitter:description"), .content(metadata.description))
//     }

//     if let image = metadata.image {
//       meta(.property("og:image"), .content(image))
//       meta(.property("twitter:image"), .content(image))
//     }

//     if let twitterCard = metadata.twitterCard {
//       meta(.property("twitter:card"), .content(twitterCard))
//     }

//     if let twitterSite = metadata.twitterSite {
//       meta(.property("twitter:site"), .content(twitterSite))
//     }

//     if let url = metadata.url {
//       meta(.property("og:url"), .content(url))
//       meta(.property("twitter:url"), .content(url))
//     }

//     meta(.property("og:type"), .content("website"))

//     /// Xcode Styling
//     style {
//       ".xml .hljs-meta{color:#6C7986}.hljs-comment,.hljs-quote{color:#6C7986}.hljs-tag,.hljs-attribute,.hljs-keyword,.hljs-selector-tag,.hljs-literal,.hljs-name{color:#FC5FA3}.hljs-template-variable{color:#FC5FA3}.hljs-code,.hljs-string,.hljs-meta-string{color:#FC6A5D}.hljs-regexp,.hljs-link{color:#5482FF}.hljs-title,.hljs-symbol,.hljs-bullet,.hljs-number{color:#41A1C0}.hljs-section,.hljs-meta{color:#FC5FA3}.hljs-class .hljs-title,.hljs-type,.hljs-built_in,.hljs-builtin-name,.hljs-params{color:#D0A8FF}.hljs-attr{color:#BF8555}.hljs-subst{color:#FFF}.hljs-formula{font-style:italic}.hljs-selector-id,.hljs-selector-class{color:#9b703f}.hljs-doctag,.hljs-strong{font-weight:bold}.hljs-emphasis{font-style:italic}"
//     }
//     script()
//       .attribute(.src("https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"))
//       .attribute(.defer)
//     script()
//       .attribute(.src("https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/languages/swift.min.js"))
//       .attribute(.defer)
//     script()
//       .attribute(.src("https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/languages/rust.min.js"))
//       .attribute(.defer)
//     script()
//       .attribute(.src("https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/languages/javascript.min.js"))
//       .attribute(.defer)
//     script()
//       .attribute(.src("https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/languages/typescript.min.js"))
//       .attribute(.defer)
//     script(.type(.module)) { "hljs.highlightAll();" }
//   }

//   public var body: some AsyncHTML & Sendable {
//     page
//     script(.type(.module), .defer) {
//       """
//       import { createApp } from "https://unpkg.com/petite-vue@0.4.1/dist/petite-vue.es.js";
//       createApp().mount();
//       """
//     }
//   }

//   public static func _render<Output>(_ html: consuming Self, into output: inout Output) async throws where Output: AsyncHTMLOutputStream {
//     let base = Base(document: html)

//     try await withDependencies {
//       $0.htmlContext = HTMLContext(.minified)
//       $0.htmlContext.styles = .groupStyles
//     } operation: {
//       try await Base<Self>._render(base, into: &output)
//     }
//   }

//   private struct Base<Document: HTMLDocument & Sendable>: HTMLDocument {
//     let document: Document

//     var head: some AsyncHTML { document.head }
//     var body: some AsyncHTML { document.body }
//   }
// }

// public struct Metadata: Hashable, Sendable {
//   public let title: String?
//   public let description: String?
//   public let image: String?
//   public let url: String?
//   public let twitterSite: String?
//   public let twitterCard: String?

//   public init(
//     title: String? = nil,
//     description: String? = nil,
//     image: String? = nil,
//     url: String? = nil,
//     twitterSite: String? = nil,
//     twitterCard: String? = nil
//   ) {
//     self.title = title
//     self.description = description
//     self.image = image
//     self.url = url
//     self.twitterSite = twitterSite
//     self.twitterCard = twitterCard
//   }
// }

// private struct BaseStyles: HTML {
//   var body: some HTML {
//     style {
//       "/*! modern-normalize v3.0.1 | MIT License | https://github.com/sindresorhus/modern-normalize */*,::after,::before{box-sizing:border-box}html{font-family:system-ui,'Segoe UI',Roboto,Helvetica,Arial,sans-serif,'Apple Color Emoji','Segoe UI Emoji';line-height:1.15;-webkit-text-size-adjust:100%;tab-size:4}body{margin:0}b,strong{font-weight:bolder}code,kbd,pre,samp{font-family:ui-monospace,SFMono-Regular,Consolas,'Liberation Mono',Menlo,monospace;font-size:1em}small{font-size:80%}sub,sup{font-size:75%;line-height:0;position:relative;vertical-align:baseline}sub{bottom:-.25em}sup{top:-.5em}table{border-color:currentcolor}button,input,optgroup,select,textarea{font-family:inherit;font-size:100%;line-height:1.15;margin:0}[type=button],[type=reset],[type=submit],button{-webkit-appearance:button}legend{padding:0}progress{vertical-align:baseline}::-webkit-inner-spin-button,::-webkit-outer-spin-button{height:auto}[type=search]{-webkit-appearance:textfield;outline-offset:-2px}::-webkit-search-decoration{-webkit-appearance:none}::-webkit-file-upload-button{-webkit-appearance:button;font:inherit}summary{display:list-item}"
//     }
//     style {
//       """
//       @font-face {
//         font-family: "CommitMono";
//         src: url("https://raw.githubusercontent.com/eigilnikolajsen/commit-mono/ecd81cdbd7f7eb2acaaa2f2f7e1a585676f9beff/src/fonts/fontlab/CommitMonoV143-VF.woff2");
//         font-style: normal;
//         font-weight: 400;
//         font-display: swap;
//       }
//       html {
//         line-height: 1.5;
//         height: 100%;
//       }
//       body {
//         background-color: #1c1c1c;
//         color: #fafafa;
//         height: 100%;
//       }
//       pre a {
//         text-decoration: none;
//       }
//       h1, h2, h3, h4, h5, figure, p, ol, ul, pre {
//         margin: 0;
//       }
//       ol[role="list"], ul[role="list"] {
//         list-style: none;
//         padding-inline: 0;
//       }
//       img, video {
//         display: block;
//         max-inline-size: 100%;
//       }
//       code {
//         font-family: "CommitMono", monospace;
//         font-feature-settings: "ss03", "ss04", "ss05";
//         line-height: 1;
//       }
//       [v-cloak] {
//         display: none;
//       }
//       a {
//         color: inherit;
//       }

//       body {
//         font-optical-sizing: auto;
//         font-size: 0.78em;
//       }

//       @media (min-width: 390px) {
//         body {
//           font-size: 0.86em;
//         }
//       }

//       @media (min-width: 480px) {
//         body {
//           font-size: 0.94em;
//         }
//       }
//       """
//     }
//   }
// }

// private struct FavIcons: HTML {
//   @Dependency(\.publicAssets) private var assets

//   var body: some HTML {
//     link(
//       .rel("icon"),
//       .custom(name: "type", value: "image/png"),
//       .custom(name: "sizes", value: "16x16"),
//       .href(assets.assets.favicon16x16Png.url.assetString)
//     )
//     link(
//       .rel("icon"),
//       .custom(name: "type", value: "image/png"),
//       .custom(name: "sizes", value: "32x32"),
//       .href(assets.assets.favicon32x32Png.url.assetString)
//     )
//     link(
//       .rel("icon"),
//       .custom(name: "type", value: "image/png"),
//       .custom(name: "sizes", value: "96x96"),
//       .href(assets.assets.favicon96x96Png.url.assetString)
//     )
//     link(
//       .rel("icon"),
//       .custom(name: "type", value: "image/png"),
//       .custom(name: "sizes", value: "128x128"),
//       .href(assets.assets.favicon128x128Png.url.assetString)
//     )
//     link(
//       .rel("icon"),
//       .custom(name: "type", value: "image/png"),
//       .custom(name: "sizes", value: "196x196"),
//       .href(assets.assets.favicon196x196Png.url.assetString)
//     )
//   }
// }
