# proxy_helper

(C)2018-2026 Takuma Watanabe takumaw@sfo.kuramae.ne.jp.

License: MIT.

## Overview

The `proxy_helper` utility reads the proxy settings from System Settings and configures
the corresponding `http_proxy`, `https_proxy`, `ftp_proxy`, and `no_proxy` environment variables.

    $ proxy_helper -s
    http_proxy="http://YOUR_HTTP_PROXY_SERVER:PORT"; export http_proxy; https_proxy="http://YOUR_HTTPS_PROXY_SERVER:PORT"; export https_proxy; ftp_proxy="http://YOUR_FTP_PROXY_SERVER:PORT"; export ftp_proxy; no_proxy="NO_PROXIES"; export no_proxy;

## Requirements

* macOS 10.13 (High Sierra) or later.

## How to install

A Homebrew tap is available at https://github.com/takumaw/homebrew-proxy_helper.

    brew tap takumaw/proxy_helper
    brew trust takumaw/proxy_helper
    brew install proxy_helper

Alternatively, you can build the binary from source. See [CONTRIBUTING.md](CONTRIBUTING.md).

## How it works

Add the following code snippet to `/etc/profile` (for Bash) or `/etc/zprofile` (for Zsh): 

    if [ -x /opt/homebrew/opt/proxy_helper/libexec/proxy_helper ]; then
        eval `/opt/homebrew/opt/proxy_helper/libexec/proxy_helper -s`
    fi

*Note: If you are on an Intel-based Mac, replace `/opt/homebrew` with `/usr/local`.*

If you install the binary to a different directory (e.g., when building from source), update the path accordingly.

You can also place the snippet in `~/.bash_profile`, `~/.zshenv`, or `~/.zprofile`.

For Csh or Tcsh users, add the following code to `/etc/csh.login` (or another initialization file):

    if ( -x /opt/homebrew/opt/proxy_helper/libexec/proxy_helper ) then
        eval `/opt/homebrew/opt/proxy_helper/libexec/proxy_helper -c`
    endif

For Fish users, add the following snippet to `~/.config/fish/config.fish`:

    if test -x /opt/homebrew/opt/proxy_helper/libexec/proxy_helper
        eval (/opt/homebrew/opt/proxy_helper/libexec/proxy_helper -f)
    end

For PowerShell users, add the following snippet to your profile script:

    if (Test-Path /opt/homebrew/opt/proxy_helper/libexec/proxy_helper) {
        /opt/homebrew/opt/proxy_helper/libexec/proxy_helper -w | Invoke-Expression
    }

You're all set! Any newly opened shells will now have the proxy environment variables automatically configured.

Restart your terminal, and you should see:

    $ export
       :
    ftp_proxy=http://YOUR_FTP_PROXY_SERVER:PORT
    http_proxy=http://YOUR_HTTP_PROXY_SERVER:PORT
    https_proxy=http://YOUR_HTTPS_PROXY_SERVER:PORT
    no_proxy=NO_PROXIES
       :
    
    $ curl -O ...
    # Commands now work through your proxy!

## Troubleshooting

### No proxy environment variables are set

If `proxy_helper` does not output any environment variables when run, check the following:

1. **System Proxy Settings**: Ensure that at least one proxy (HTTP, HTTPS, FTP, or Bypass proxy settings) is actually enabled and configured in your macOS **System Settings > Network > [Your Active Interface] > Proxies**. If no proxies are enabled, `proxy_helper` exits silently without printing any variables.
2. **Evaluate PAC Manually**: If your network uses a Proxy Auto-Configuration (PAC) script, you can manually test proxy resolution for a specific URL using the `-p` (or `--pac`) and `-u` (or `--url`) options:
   ```bash
   /opt/homebrew/opt/proxy_helper/libexec/proxy_helper -p -u https://www.google.com
   ```
   *Note: If you are on an Intel-based Mac, replace `/opt/homebrew` with `/usr/local`.*
3. **Execution Check**: Ensure the shell profile script is correctly calling the `eval` (or `Invoke-Expression` for PowerShell) command with the appropriate path and shell flag (`-s`, `-c`, `-f`, or `-w`).

## Documentation

For detailed information on available options and how `no_proxy` rules are evaluated, please refer to the manual page included in the installation:

```bash
man proxy_helper
```
