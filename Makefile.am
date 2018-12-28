SWIFT = swift
SWIFTLINT = swiftlint

.PHONY: all
all:
	$(SWIFT) build -c release --disable-sandbox

.PHONY: clean
clean:
	$(RM) -r .build

.PHONY: install
install: all
	$(MKDIR_P) "$(libexecdir)"
	$(MKDIR_P) "$(mandir)/man8"
	$(INSTALL_PROGRAM) ".build/release/ProxyHelper" "$(libexecdir)/proxy_helper"
	$(INSTALL_DATA) "ManPage/proxy_helper.8" "$(mandir)/man8/proxy_helper.8"

.PHONY: uninstall
uninstall:
	$(RM) "$(libexecdir)/proxy_helper"
	$(RM) "$(mandir)/man8/proxy_helper.8"

.PHONY: check
check:
	$(SWIFT) test

.PHONY: lint
lint:
	$(SWIFTLINT)
