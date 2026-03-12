import Elementary

extension HTMLAttribute {
  static func aria(_ name: String, value: String?, mergeBy action: HTMLAttributeMergeAction = .replacing) -> Self {
    Self(name: "aria-\(name)", value: value, mergedBy: action)
  }
}