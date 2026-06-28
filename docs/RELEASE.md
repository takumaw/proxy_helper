# Release Process

Releases are driven by Git tags and managed via GitHub Actions.

Release notes are maintained in [HISTORY.md](../HISTORY.md).

## Version format

Git tags use a leading `v`:

```text
v0.1.0
```

`HISTORY.md` headings do not use a leading `v`:

```markdown
## 0.1.0
```

## Release assets

A release contains a single compressed archive that targets macOS:

```text
proxy_helper-vX.Y.Z-macOS.tar.gz
```

The tarball has the following prefix directory structure:

```text
libexec/
  └── proxy_helper          # Universal binary (x86_64 / arm64)
share/
  └── man/
      └── man8/
          └── proxy_helper.8 # Man page documentation
```

## Pre-release checklist

Before creating a tag:

* `README.md` is up to date.
* `HISTORY.md` contains the release entry under the heading `## X.Y.Z`.
* `ManPage/proxy_helper.8` is updated if CLI options changed.
* CI passes on `main`.
* Local builds and tests pass.

## Creating a release

To trigger a release (e.g., `v0.1.0`), push a signed Git tag representing the version:

```bash
# 1. Update HISTORY.md, README.md, etc., commit changes
git add HISTORY.md README.md
git commit -m "Prepare v0.1.0 release"

# 2. Create a signed tag
git tag -s v0.1.0 -m "Release v0.1.0"

# 3. Push main branch and the tag
git push origin main
git push origin v0.1.0
```

The release workflow is triggered automatically by pushing a tag matching `v*`.

## Workflow behavior

The GitHub Actions release workflow (`.github/workflows/release.yml`) executes the following steps:

1. **Checkout**: Checks out the tag codebase.
2. **Test**: Runs `swift test --disable-sandbox` to ensure regressions are caught.
3. **Build**: Compiles a Universal binary (targeting both `arm64` and `x86_64` macOS architectures) with release optimizations.
4. **Package**: Structures the binary and man page into a prefix layout (`bin/` and `share/`) and packages them as `proxy_helper-vX.Y.Z-macOS.tar.gz`.
5. **Release Notes**: Uses `awk` to extract the release changelog section matching the tag version from `HISTORY.md`.
6. **Publish**: Creates a GitHub Release, attaches the extracted release notes, and uploads the `.tar.gz` archive.

## Failure cases

The workflow will fail if:
* The pushed tag does not match `v*`.
* The corresponding version header (e.g. `## 0.1.0`) is missing in `HISTORY.md`.
* The test or build step fails.

If the workflow fails before creating a release, fix the root cause on `main`, update/move the tag, and push again.
If it fails mid-release, clean up the incomplete GitHub Release and tag in the web interface and git before retrying.

## Homebrew Formula Update

After a release has successfully completed on GitHub, the custom Homebrew tap (`takumaw/homebrew-proxy_helper`) needs to be updated to point to the new release tarball.

1. **Calculate SHA-256 Hash**:
   Download the released tarball (`proxy_helper-vX.Y.Z-macOS.tar.gz`) from GitHub, and calculate its SHA-256 checksum:
   ```bash
   shasum -a 256 proxy_helper-vX.Y.Z-macOS.tar.gz
   ```

2. **Update the Formula**:
   In your Homebrew tap repository (`homebrew-proxy_helper`), update the Formula file (usually `Formula/proxy_helper.rb`):
   - Update `url` to point to the new release tarball URL.
   - Update `sha256` with the checksum calculated above.
   - Ensure the `install` method correctly installs the `libexec` binary and the man page:
     ```ruby
     def install
       libexec.install "libexec/proxy_helper"
       man8.install "share/man/man8/proxy_helper.8"
     end
     ```

3. **Commit and Push**:
   Commit the changes in `homebrew-proxy_helper` and push to remote.
   ```bash
   git add Formula/proxy_helper.rb
   git commit -m "Update proxy_helper to vX.Y.Z"
   git push origin main
   ```
