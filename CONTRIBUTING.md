# CONTRIBUTING

This project is small and focused. Keep changes minimal, clean, and well-tested.

## Requirements

Development targets macOS with Swift.

Required tools:

* macOS 10.13 or later (Universal binary target macOS 10.13+)
* Xcode or Xcode Command Line Tools (with Swift)

## Build & install

### Building via Swift Package Manager (recommended for development)

To build the project in debug mode:

```bash
swift build
```

To build a release-optimized binary:

```bash
swift build -c release
```

### Troubleshooting: Synchronized directories (e.g., iCloud Drive)

If your workspace is located in a synchronized directory like iCloud Drive, the macOS SwiftPM sandbox constraints may block module cache generation in `/var/folders/`. 

To bypass these sandbox blocks, explicitly redirect the module cache directory and disable sandbox checks during build:

```bash
CLANG_MODULE_CACHE_PATH=.build/ModuleCache SWIFT_MODULE_CACHE_PATH=.build/ModuleCache swift build -c release --disable-sandbox
```

## Test

To run the XCTest suite:

```bash
swift test
```

### Troubleshooting tests under sandbox constraints

If running inside a synced directory, run the tests by redirecting the module cache and disabling sandbox constraints:

```bash
CLANG_MODULE_CACHE_PATH=.build/ModuleCache SWIFT_MODULE_CACHE_PATH=.build/ModuleCache swift test --disable-sandbox -debug-info-format none
```

### Testing guidelines

* **Automatic Discovery**: For macOS XCTest suite execution, all test case methods inside `ProxyHelperTests` **must** be prefixed with `test` (e.g., `testQuitsCorrectly`), otherwise they will be ignored by the test runner.
* **Integration Tests**: Tests launch the built executable via `Process`. Ensure the binary name in the test checks points to the lowercase `"proxy_helper"`.

## Code style & linting

### SwiftLint

This project enforces Swift style and conventions using SwiftLint. Ensure your changes do not introduce lint warnings or errors. Linter settings are configured in `.swiftlint.yml`.

### Copyright header

Every Swift source file must start with the standard copyright comment header. For example:

```swift
/*
 * Copyright (c) 2018-2026 Takuma Watanabe.
 */
```

Ensure new files include a matching header with the appropriate year.

## Documentation

Design changes should update [docs/DESIGN.md](docs/DESIGN.md).

Release process changes should update [docs/RELEASE.md](docs/RELEASE.md).
