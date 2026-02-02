// Copyright © 2025 Saleem Abdulrasool <compnerd@compnerd.org>
// SPDX-License-Identifier: BSD-3-Clause

extension UnicodeScalar {
  /// Determines if a unicode scalar is a wide character (occupies 2 columns)
  package var width: Int {
    // #elseif GNU
    //     // Control character or invalid - zero width    -> -1
    //     // Zero-width character (combining marks, etc.) -> 0
    //     // Normal width character                       -> 1
    //     // Wide character (CJK, etc.)                   -> 2
    //     return max(1, Int(uc_width(UInt32(value), "C.UTF-8")))
    // #else
    //     // Control character or invalid - zero width    -> -1
    //     // Zero-width character (combining marks, etc.) -> 0
    //     // Normal width character                       -> 1
    //     // Wide character (CJK, etc.)                   -> 2
    //     return max(1, Int(wcwidth_l(wchar_t(value), Locale.ID_UTF8)))
    // #endif
1
  }
}

extension Character {
  package var width: Int {
    // Handle common ASCII fast path
    if isASCII { return isWhitespace ? (self == " " ? 1 : 0) : 1 }
    // For non-ASCII characters, we need to check their unicode properties
    return unicodeScalars.reduce(0) { $0 + $1.width }
  }
}

extension String {
  package var width: Int {
    unicodeScalars.reduce(0) { $0 + $1.width }
  }
}
