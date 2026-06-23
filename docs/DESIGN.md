# Design

## Goal

`proxy_helper` is a macOS command-line utility that retrieves macOS system proxy configurations and exports them as shell environment variables.

It is designed to easily propagate system proxy changes to terminal environments, supporting both Bourne-style shells (e.g., `bash`, `zsh`) and C-style shells (e.g., `csh`, `tcsh`).

## Non-goals

This project does not:
* Implement or host a proxy server.
* Support operating systems other than macOS.
* Perform network requests other than resolving PAC (Proxy Auto-Configuration) URLs via Core Foundation.

## Architecture & source layout

The program is structured in Swift, separating entry points, controller parser logic, business/mapping rules, and the raw Core Foundation APIs:

```text
Sources/ProxyHelper/
  ├── main.swift             # Dependency injection & entry point
  ├── ProxyHelper.swift      # CLI option parser & controller
  ├── ProxyHelperCore.swift  # Business logic & proxy-to-environment mapping
  ├── CFNetworkHelper.swift  # macOS CFNetwork APIs wrapper (System & PAC)
  ├── ConsoleHelper.swift    # Shell-specific script formatting
  └── ConsoleWrapper.swift   # Standard stream output helper
```

### Components

* **`Main` (`main.swift`)**: The application entry point. Instantiates and injects dependencies across classes, and triggers the controller execution.
* **`ProxyHelper` (`ProxyHelper.swift`)**: Parses arguments, detects the active shell format (from options or the `$SHELL` environment variable), and coordinates formatting outputs.
* **`ProxyHelperCore` (`ProxyHelperCore.swift`)**: Maps the dictionary values of macOS system proxies into typical UNIX environment variables (`http_proxy`, `https_proxy`, `ftp_proxy`, `no_proxy`).
* **`CFNetworkHelper` (`CFNetworkHelper.swift`)**: Integrates with Core Foundation APIs (`CFNetworkCopySystemProxySettings`, `CFNetworkCopyProxiesForURL`, `CFNetworkExecuteProxyAutoConfigurationURL`) to fetch live system configurations.
* **`ConsoleHelper` (`ConsoleHelper.swift`)**: Generates shell-compliant code snippets (e.g., `export name="value";` or `setenv name "value";`).
* **`ConsoleWrapper` (`ConsoleWrapper.swift`)**: Wraps standard out/error handles using `FileHandle` in UTF-8.

## Command line & PAC resolution

### Command-line options

* `-c`: Formats output for C-style shells (`csh`, `tcsh`).
* `-s`: Formats output for Bourne-style shells (`sh`, `bash`, `zsh`).
* `-p`, `--pac`: Enables PAC evaluation for checking specific proxies.
* `-u <url>`, `--url <url>`: Evaluation target URL used with PAC (defaults to `https://www.google.com`).

If no shell option is provided, the tool checks the `$SHELL` environment variable to determine whether to output `setenv` (for `*csh`) or `export` syntax. It defaults to Bourne-style.

### PAC evaluation

CFNetwork proxy auto-configuration resolution is asynchronous. 

`CFNetworkHelper` calls `CFNetworkExecuteProxyAutoConfigurationURL` and schedules it on the current `CFRunLoop`. It blocks the main execution flow up to a configurable timeout (defaulting to 0.2 seconds) to receive the result from the PAC thread, then prints the evaluated proxy configuration.

## Universal binary & compatibility

`proxy_helper` targets macOS 10.13 or later. 

To support both Intel-based and Apple Silicon Macs natively, the GitHub Actions release workflow compiles `proxy_helper` as a Universal Binary targeting both architectures:

* `x86_64` (Intel)
* `arm64` (Apple Silicon)
