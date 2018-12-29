SWIFT = swift
SWIFTLINT = swiftlint

# Build all artifacts
.PHONY: all
all:
	$(SWIFT) build -c release $(SWIFTBBUILDFLAGS)

# Clean build results and caches
.PHONY: clean
clean:
	$(RM) -r .build

# Install only (without building artifacts)
.PHONY: install-only
install-only:
	$(MKDIR_P) "$(libexecdir)"
	$(MKDIR_P) "$(mandir)/man8"
	$(INSTALL_PROGRAM) ".build/release/proxy_helper" "$(libexecdir)/proxy_helper"
	$(INSTALL_DATA) "ManPage/proxy_helper.8" "$(mandir)/man8/proxy_helper.8"

# Install articacts
.PHONY: install
install: all install-only

# Uninstall artifacts
.PHONY: uninstall
uninstall:
	$(RM) "$(libexecdir)/proxy_helper"
	$(RM) "$(mandir)/man8/proxy_helper.8"

# Run tests
.PHONY: check
check:
	$(SWIFT) test

# Run linter
.PHONY: lint
lint:
	$(SWIFTLINT) $(SWIFTLINTFLAGS)

# Generate Xcode Project
.PHONY: generate-xcodeproj
generate-xcodeproj:
	$(SWIFT) package generate-xcodeproj

# Clean Xcode Project
.PHONY: clean-xcodeproj
clean-xcodeproj:
	$(RM) -r ProxyHelper.xcodeproj
