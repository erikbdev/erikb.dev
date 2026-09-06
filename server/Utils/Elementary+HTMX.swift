import Elementary
import HTTPTypes

extension HTMLAttribute where Tag: HTMLTrait.Attributes.Global {
  /// A namespace for htmx attributes.
  public enum hx {}
}

extension HTMLAttribute.hx {
  public static func get(_ url: String) -> HTMLAttribute<Tag> {
    .init(name: "hx-get", value: url)
  }

  public static func post(_ url: String) -> HTMLAttribute<Tag> {
    .init(name: "hx-post", value: url)
  }

  public static func put(_ url: String) -> HTMLAttribute<Tag> {
    .init(name: "hx-put", value: url)
  }

  public static func patch(_ url: String) -> HTMLAttribute<Tag> {
    .init(name: "hx-patch", value: url)
  }

  public static func delete(_ url: String) -> HTMLAttribute<Tag> {
    .init(name: "hx-delete", value: url)
  }

  /// Overrides the query string used for a request, independent of its HTTP method. New in htmx v4.
  public static func query(_ value: String) -> HTMLAttribute<Tag> {
    .init(name: "hx-query", value: value)
  }

  // MARK: Request control

  public static func trigger(_ value: HTMLAttributeValue.HTMX.EventTrigger) -> HTMLAttribute<Tag> {
    .init(name: "hx-trigger", value: value.rawValue, mergedBy: .appending(separatedBy: ", "))
  }

  public static func trigger(_ value: HTMLAttributeValue.HTMX.PollingTrigger) -> HTMLAttribute<Tag> {
    .init(name: "hx-trigger", value: value.rawValue, mergedBy: .appending(separatedBy: ", "))
  }

  public static func swap(_ value: HTMLAttributeValue.HTMX.ModifiedSwapTarget) -> HTMLAttribute<Tag> {
    .init(name: "hx-swap", value: value.rawValue)
  }

  public static func target(_ selector: String) -> HTMLAttribute<Tag> {
    .init(name: "hx-target", value: selector)
  }

  public static func select(_ selector: String) -> HTMLAttribute<Tag> {
    .init(name: "hx-select", value: selector)
  }

  public static func selectOOB(
    _ selector: String,
    _ swap: HTMLAttributeValue.HTMX.SwapTarget? = nil
  ) -> HTMLAttribute<Tag> {
    if let swap {
      .init(name: "hx-select-oob", value: "\(selector):\(swap.rawValue)", mergedBy: .appending(separatedBy: ","))
    } else {
      .init(name: "hx-select-oob", value: selector, mergedBy: .appending(separatedBy: ","))
    }
  }

  public static func swapOOB(_ value: Bool) -> HTMLAttribute<Tag> {
    .init(name: "hx-swap-oob", value: value.stringValue)
  }

  public static func swapOOB(
    _ swap: HTMLAttributeValue.HTMX.SwapTarget,
    _ selector: String? = nil
  ) -> HTMLAttribute<Tag> {
    if let selector {
      .init(name: "hx-swap-oob", value: "\(swap.rawValue):\(selector)")
    } else {
      .init(name: "hx-swap-oob", value: swap.rawValue)
    }
  }

  public static func confirm(_ value: String) -> HTMLAttribute<Tag> {
    .init(name: "hx-confirm", value: value)
  }

  /// Controls how requests from the same element are synchronized (`drop`, `abort`, `replace`, `queue …`).
  public static func sync(_ value: String) -> HTMLAttribute<Tag> {
    .init(name: "hx-sync", value: value)
  }

  /// Routes error responses by status code to their own target/swap. New in htmx v4.
  public static func status(_ value: String) -> HTMLAttribute<Tag> {
    .init(name: "hx-status", value: value)
  }

  // MARK: Data

  public static func vals(_ value: String) -> HTMLAttribute<Tag> {
    .init(name: "hx-vals", value: value)
  }

  public static func include(_ value: String) -> HTMLAttribute<Tag> {
    .init(name: "hx-include", value: value)
  }

  public static func headers(_ value: String) -> HTMLAttribute<Tag> {
    .init(name: "hx-headers", value: value)
  }

  public static func encoding(_ value: String) -> HTMLAttribute<Tag> {
    .init(name: "hx-encoding", value: value)
  }

  /// Runs inline JavaScript in response to an event on the element, e.g. `.on("click", "console.log('hi')")`
  /// emits `hx-on:click`.
  public static func on(_ event: String, _ script: String) -> HTMLAttribute<Tag> {
    .init(name: "hx-on:\(event)", value: script)
  }

  // MARK: History

  public static func pushURL(_ url: String) -> HTMLAttribute<Tag> {
    .init(name: "hx-push-url", value: url)
  }

  public static func pushURL(_ value: Bool) -> HTMLAttribute<Tag> {
    .init(name: "hx-push-url", value: value.stringValue)
  }

  public static func replaceURL(_ url: String) -> HTMLAttribute<Tag> {
    .init(name: "hx-replace-url", value: url)
  }

  public static func replaceURL(_ value: Bool) -> HTMLAttribute<Tag> {
    .init(name: "hx-replace-url", value: value.stringValue)
  }

  /// Marks the element used as the page's history snapshot boundary, in place of `<body>`.
  public static var historyElt: HTMLAttribute<Tag> {
    .init(name: "hx-history-elt", value: .none)
  }

  // MARK: Enhancement

  public static func boost(_ value: Bool) -> HTMLAttribute<Tag> {
    .init(name: "hx-boost", value: value.stringValue)
  }

  /// Preloads a link's target ahead of interaction (`mousedown`, `mouseover`, …). New in htmx v4.
  public static func preload(_ value: String = "mousedown") -> HTMLAttribute<Tag> {
    .init(name: "hx-preload", value: value)
  }

  /// Names the element shown while a request is pending. New in htmx v4.
  public static func pending(_ value: String) -> HTMLAttribute<Tag> {
    .init(name: "hx-pending", value: value)
  }

  // MARK: Advanced

  public static func indicator(_ value: String) -> HTMLAttribute<Tag> {
    .init(name: "hx-indicator", value: value)
  }

  public static func validate(_ value: Bool) -> HTMLAttribute<Tag> {
    .init(name: "hx-validate", value: value.stringValue)
  }

  public static var disable: HTMLAttribute<Tag> {
    .init(name: "hx-disable", value: .none)
  }

  public static var ignore: HTMLAttribute<Tag> {
    .init(name: "hx-ignore", value: .none)
  }

  public static var preserve: HTMLAttribute<Tag> {
    .init(name: "hx-preserve", value: .none)
  }

  public static func disabledElt(_ value: String) -> HTMLAttribute<Tag> {
    .init(name: "hx-disabled-elt", value: value)
  }

  public static func ext(_ value: HTMLAttributeValue.HTMX.Extension) -> HTMLAttribute<Tag> {
    .init(name: "hx-ext", value: value.rawValue, mergedBy: .appending(separatedBy: ","))
  }

  public static func params(_ value: String) -> HTMLAttribute<Tag> {
    .init(name: "hx-params", value: value)
  }

  public static func request(_ value: String) -> HTMLAttribute<Tag> {
    .init(name: "hx-request", value: value)
  }
}

// MARK: - Attribute value builders

public extension HTMLAttributeValue {
  /// A namespace for htmx attribute value types. See https://four.htmx.org/reference/
  enum HTMX {}
}

public extension HTMLAttributeValue.HTMX {
  /// A `hx-swap`/`hx-swap-oob` swap style, including htmx v4's morph-swap styles.
  struct SwapTarget: RawRepresentable, ExpressibleByStringLiteral {
    public var rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(stringLiteral value: String) { rawValue = value }

    public static var innerHTML: Self { "innerHTML" }
    public static var outerHTML: Self { "outerHTML" }
    public static var textContent: Self { "textContent" }
    public static var beforeBegin: Self { "beforebegin" }
    public static var afterBegin: Self { "afterbegin" }
    public static var beforeEnd: Self { "beforeend" }
    public static var afterEnd: Self { "afterend" }
    public static var delete: Self { "delete" }
    public static var none: Self { "none" }
    public static var upsert: Self { "upsert" }
    /// Morphs content inside the element, preserving state and focus.
    public static var innerMorph: Self { "innerMorph" }
    /// Morphs the entire element, preserving state and focus.
    public static var outerMorph: Self { "outerMorph" }
    /// Morphs the target's attributes, then replaces its children.
    public static var outerSync: Self { "outerSync" }
  }

  struct ModifiedSwapTarget: RawRepresentable {
    public var rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(_ swapTarget: SwapTarget) { rawValue = swapTarget.rawValue }

    public static var innerHTML: Self { .init(.innerHTML) }
    public static var outerHTML: Self { .init(.outerHTML) }
    public static var textContent: Self { .init(.textContent) }
    public static var beforeBegin: Self { .init(.beforeBegin) }
    public static var afterBegin: Self { .init(.afterBegin) }
    public static var beforeEnd: Self { .init(.beforeEnd) }
    public static var afterEnd: Self { .init(.afterEnd) }
    public static var delete: Self { .init(.delete) }
    public static var none: Self { .init(.none) }
    public static var upsert: Self { .init(.upsert) }
    public static var innerMorph: Self { .init(.innerMorph) }
    public static var outerMorph: Self { .init(.outerMorph) }
    public static var outerSync: Self { .init(.outerSync) }
    public static var `default`: Self { .init(rawValue: "") }
  }
}

public extension HTMLAttributeValue.HTMX.ModifiedSwapTarget {
  consuming func transition(_ value: Bool) -> Self { appending(modifier: "transition", value: value.stringValue) }
  consuming func swap(_ duration: String) -> Self { appending(modifier: "swap", value: duration) }
  consuming func settle(_ duration: String) -> Self { appending(modifier: "settle", value: duration) }
  consuming func ignoreTitle(_ value: Bool) -> Self { appending(modifier: "ignoreTitle", value: value.stringValue) }
  consuming func scroll(_ value: HTMLAttributeValue.HTMX.ScrollModifier) -> Self { appending(modifier: "scroll", value: value.rawValue) }
  consuming func show(_ value: HTMLAttributeValue.HTMX.ScrollModifier) -> Self { appending(modifier: "show", value: value.rawValue) }
  consuming func focusScroll(_ value: Bool) -> Self { appending(modifier: "focus-scroll", value: value.stringValue) }
  consuming func target(_ selector: String) -> Self { appending(modifier: "target", value: selector) }
  /// Controls whether the response's outer element is stripped before swapping. New in htmx v4.
  consuming func strip(_ value: Bool) -> Self { appending(modifier: "strip", value: value.stringValue) }
  /// Controls behavior when no main content remains after stripping. New in htmx v4.
  consuming func swapEmpty(_ value: Bool) -> Self { appending(modifier: "swapEmpty", value: value.stringValue) }

  internal consuming func appending(modifier: String, value: String) -> Self {
    if !rawValue.isEmpty { rawValue += " " }
    rawValue += modifier
    rawValue += ":"
    rawValue += value
    return self
  }
}

public extension HTMLAttributeValue.HTMX {
  struct ScrollModifier: RawRepresentable {
    public var rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }

    public static var top: Self { .init(rawValue: "top") }
    public static var bottom: Self { .init(rawValue: "bottom") }
    public static var none: Self { .init(rawValue: "none") }

    public static func top(_ selector: String) -> Self { .init(rawValue: "\(selector):top") }
    public static func bottom(_ selector: String) -> Self { .init(rawValue: "\(selector):bottom") }
  }
}

public extension HTMLAttributeValue.HTMX {
  struct TriggerEvent: RawRepresentable {
    public var rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }

    public static var load: Self { .init(rawValue: "load") }
    public static var revealed: Self { .init(rawValue: "revealed") }
    public static var intersect: Self { .init(rawValue: "intersect") }
  }

  struct EventTrigger: RawRepresentable {
    public var rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }

    public static func event(_ event: HTMLAttributeValue.MouseEvent) -> Self { .init(rawValue: "\(event.rawValue)") }
    public static func event(_ event: HTMLAttributeValue.KeyboardEvent) -> Self { .init(rawValue: "\(event.rawValue)") }
    public static func event(_ event: HTMLAttributeValue.FormEvent) -> Self { .init(rawValue: "\(event.rawValue)") }
    public static func event(_ event: HTMLAttributeValue.HTMX.TriggerEvent) -> Self { .init(rawValue: "\(event.rawValue)") }
  }

  struct PollingTrigger: RawRepresentable {
    public var rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }

    public static func every(_ interval: String) -> Self { .init(rawValue: "every \(interval)") }
  }
}

public extension HTMLAttributeValue.HTMX.EventTrigger {
  consuming func once() -> Self { appending(modifier: "once") }
  consuming func changed() -> Self { appending(modifier: "changed") }
  consuming func delay(_ value: String) -> Self { appending(modifier: "delay", value: value) }
  consuming func throttle(_ value: String) -> Self { appending(modifier: "throttle", value: value) }
  consuming func from(_ selector: String) -> Self { appending(modifier: "from", value: selector) }
  consuming func target(_ selector: String) -> Self { appending(modifier: "target", value: selector) }
  consuming func consume() -> Self { appending(modifier: "consume") }
  consuming func prevent() -> Self { appending(modifier: "prevent") }
  consuming func halt() -> Self { appending(modifier: "halt") }
  consuming func capture() -> Self { appending(modifier: "capture") }
  consuming func passive() -> Self { appending(modifier: "passive") }

  internal consuming func appending(modifier: String, value: String? = nil) -> Self {
    rawValue += " "
    rawValue += modifier
    if let value {
      rawValue += ":"
      rawValue += value
    }
    return self
  }
}

public extension HTMLAttributeValue.HTMX {
  struct Extension: RawRepresentable, ExpressibleByStringLiteral {
    public var rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(stringLiteral value: String) { rawValue = value }
  }
}

extension Bool {
  fileprivate var stringValue: String { self ? "true" : "false" }
}

// MARK: - HTTP header fields

extension HTTPField.Name {
  /// A namespace for htmx's request/response header names. See https://four.htmx.org/reference/
  public enum hx {}
}

extension HTTPField.Name.hx {
  // MARK: Request headers

  /// Indicates the request was made by htmx.
  public static let request = HTTPField.Name("HX-Request")!

  /// Distinguishes between "partial" or "full" page requests.
  public static let requestType = HTTPField.Name("HX-Request-Type")!

  /// Contains the browser's current URL when the request started.
  public static let currentURL = HTTPField.Name("HX-Current-URL")!

  /// Identifies the element that triggered the request.
  public static let source = HTTPField.Name("HX-Source")!

  /// Identifies the element that will receive the response.
  public static let target = HTTPField.Name("HX-Target")!

  /// Indicates the request came from a boosted (`hx-boost`) navigation.
  public static let boosted = HTTPField.Name("HX-Boosted")!

  /// Indicates the request is a history navigation (back/forward).
  public static let historyRestoreRequest = HTTPField.Name("HX-History-Restore-Request")!

  // MARK: Response headers

  /// Triggers client-side events via `htmx.trigger()`.
  public static let trigger = HTTPField.Name("HX-Trigger")!

  /// Redirects the client without a full page load.
  public static let location = HTTPField.Name("HX-Location")!

  /// Redirects the client by setting `location.href`.
  public static let redirect = HTTPField.Name("HX-Redirect")!

  /// Reloads the page with `location.reload()`.
  public static let refresh = HTTPField.Name("HX-Refresh")!

  /// Overrides the swap target specified by the element.
  public static let retarget = HTTPField.Name("HX-Retarget")!

  /// Overrides the swap style specified by the element.
  public static let reswap = HTTPField.Name("HX-Reswap")!

  /// Overrides the content selection specified by the element.
  public static let reselect = HTTPField.Name("HX-Reselect")!

  /// Replaces the current URL in the browser's history.
  public static let replaceURL = HTTPField.Name("HX-Replace-Url")!

  /// Pushes a URL into the browser's history stack.
  public static let pushURL = HTTPField.Name("HX-Push-Url")!
}
