# Coding Agent Guidelines for `proxy_helper`

This document provides essential guidelines, build commands, and troubleshooting tips for AI coding agents working on this repository.

## Architecture Overview

The utility is written in Swift and has a decoupled architecture to manage dependencies:

```
[main.swift] 
      │ (Entry Point)
      ▼
[ProxyHelper.swift] (Controller / Argument Parser)
      │
      ▼
[ProxyHelperCore.swift] (Business Logic & Environment Variable Mapping)
      │
      ▼
[CFNetworkHelper.swift] (macOS CFNetwork APIs Wrapper)
```

- **`CFNetworkHelper`**: Interacts with macOS CoreFoundation/CFNetwork to read system proxies and execute PAC resolution.
- **`ProxyHelperCore`**: Maps the raw proxy structures into shell environment variables (`http_proxy`, `https_proxy`, `ftp_proxy`, `no_proxy`).
- **`ProxyHelper`**: Parses command-line flags (`-s` / `-c` for shells, `-p` for PAC, `-u` for evaluation URL) and triggers execution.

---

## Build & Test Commands (Crucial)

If the workspace path is located inside a synchronized directory (e.g., **iCloud Drive / Mobile Documents**), macOS SwiftPM sandbox constraints will block module cache generation in `/var/folders/`.

Use the following commands to bypass sandbox blocks by redirecting the module cache and disabling debug symbols generation (`dsymutil` sandbox blocks).

### Run Tests
```bash
CLANG_MODULE_CACHE_PATH=.build/ModuleCache SWIFT_MODULE_CACHE_PATH=.build/ModuleCache swift test --disable-sandbox -debug-info-format none
```

### Build Program
```bash
CLANG_MODULE_CACHE_PATH=.build/ModuleCache SWIFT_MODULE_CACHE_PATH=.build/ModuleCache swift build -c release --disable-sandbox
```

---

## Testing Guidelines

- **Automatic Discovery**: For macOS XCTest suite execution, all test case methods inside `ProxyHelperTests` **must** be prefixed with `test` (e.g., `testQuitsCorrectly`), otherwise they will be ignored by the runner.
- **Integration Tests**: Tests launch the built executable via `Process`. Ensure the binary name in the test checks points to the lowercase `"proxy_helper"`.

---

## Code Style & Linting

- **SwiftLint**: The project uses SwiftLint to enforce Swift style and conventions. Ensure your changes do not introduce lint warnings or errors. Linter settings are configured in `.swiftlint.yml`.
- **Copyright Header**: Every Swift source file must start with the standard copyright comment header. Refer to existing Swift source files (such as `Sources/ProxyHelper/main.swift`) for the exact format and ensure new files include a matching header.


---

## Documentation Files

- **`README.md`**: Main guide and synopsis.
- **`HISTORY.md`**: Release notes. Update the top section whenever adding new features or preparing a release.
- **`ManPage/proxy_helper.8`**: Program manpage in mdoc/troff format. Update this when modifying command-line options.

---

## CI & Release Workflow

The repository includes a GitHub Actions workflow that automates testing, building, and publishing releases.

### Triggering a Release
A release is automatically triggered by pushing a version tag (e.g., `v0.1.0`):

```bash
# 1. Update HISTORY.md (crucial - see below)
# 2. Commit and push your changes to main
# 3. Create and push a tag
git tag v0.1.0
git push origin v0.1.0
```

### Release Notes Generation
The CI workflow automatically extracts the release notes from **`HISTORY.md`** based on the version tag being pushed. 

For example, when pushing tag `v0.1.0`, the workflow parses the section under `## 0.1.0` up to the next version header. Therefore, **always ensure that `HISTORY.md` is updated with the new version section before pushing the tag**.

