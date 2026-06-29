# HISTORY

## 0.2.0

  * Replaced `fatalError` and force-casts with proper error propagation (`ProxyError`, `throws`) for graceful failure.
  * Changed the release artifact directory structure from `bin/` to `libexec/`.
  * Expanded unit test coverage for CFNetwork dictionary parsing logic using mock objects.

## 0.1.0

  * Added Support for Proxy Auto-Configuration (PAC) script evaluation with the `-p`/`--pac` and `-u`/`--url` options.
  * Enhanced command line argument parsing.
  * Fixed XCTest cases auto-detection and execution issue on macOS.

## 0.0.4

  * Refactored application structure to split controller/logic.

## 0.0.3

  * Added HISTORY.md.
  * Refactored application structure.
  * Removed SwiftPM dependency from the package definition.
  * Fixed man page error.
  * Enabled swiftlint.

## 0.0.2

  * Removed SwiftPM dependency to reduce binary size. (1.7MiB -> 110KiB)
  * Enhanced man page.

## 0.0.1

  * Initial release.
