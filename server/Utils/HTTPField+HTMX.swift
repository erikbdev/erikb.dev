import HTTPTypes

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
