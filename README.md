# proxy_helper

(C)2018-2026 WATANABE Takuma takumaw@sfo.kuramae.ne.jp.

Licence: MIT.

## What is this

The `proxy_helper` utility reads the proxy settings from System Preferences and constructs
the `http_proxy`, `https_proxy`, `ftp_proxy` and `no_proxy` environment variables respectively.

    $ proxy_helper -s
    http_proxy="http://YOUR_HTTP_PROXY_SERVER:PORT"; export http_proxy; https_proxy="http://YOUR_HTTPS_PROXY_SERVER:PORT"; export https_proxy; ftp_proxy="http://YOUR_FTP_PROXY_SERVER:PORT"; export ftp_proxy; no_proxy="NO_PROXIES"; export no_proxy;

## Requirements

* macOS 10.13 (High Sierra) or later.

## How to install

Homebrew tap is available at https://github.com/takumaw/homebrew-proxy_helper.

    brew tap takumaw/proxy_helper
    brew trust takumaw/proxy_helper
    brew install proxy_helper

Or, you may build a binary from the source. See [CONTRIBUTING.md](CONTRIBUTING.md).

## How it works

In your `/etc/profile` for BASH, or `/etc/zprofile` for ZSH, add the following code snippet: 

    if [ -x /opt/homebrew/opt/proxy_helper/libexec/proxy_helper ]; then
        eval `/opt/homebrew/opt/proxy_helper/libexec/proxy_helper -s`
    fi

*Note: If you are on an Intel-based Mac, replace `/opt/homebrew` with `/usr/local`.*

Change the path to the binary when you install it to another directory (e.g. built from the source.)

You may innstead put the snippet on `~/.bash_profile`, `~/.zshenv` or `~/.zprofile`.

For CSH or TCSH users, put the following code to e.g. `/etc/csh.login`:

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

That's all set! All your newly invoked shells now have proxy environment variables set.

Re-open your terminal, and you see:

    $ export
       :
    ftp_proxy=http://YOUR_FTP_PROXY_SERVER:PORT
    http_proxy=http://YOUR_HTTP_PROXY_SERVER:PORT
    https_proxy=http://YOUR_HTTPS_PROXY_SERVER:PORT
    no_proxy=NO_PROXIES
       :
    
    $ curl -O ...
    # Commands works behind your proxy!

## Troubleshooting

### No proxy environment variables are set

If you run `proxy_helper` and it does not output any variables, verify the following:

1. **System Proxy Settings**: Ensure that at least one proxy (HTTP, HTTPS, FTP, or Bypass proxy settings) is actually enabled and configured in your macOS **System Settings > Network > [Your Active Interface] > Proxies**. If no proxies are enabled, `proxy_helper` exits silently without printing any variables.
2. **Evaluate PAC Manually**: If your network uses a Proxy Auto-Configuration (PAC) script, you can manually test proxy resolution for a specific URL using the `-p` (or `--pac`) and `-u` (or `--url`) options:
   ```bash
   /opt/homebrew/opt/proxy_helper/libexec/proxy_helper -p -u https://www.google.com
   ```
   *Note: If you are on an Intel-based Mac, replace `/opt/homebrew` with `/usr/local`.*
3. **Execution Check**: Ensure the shell profile script is correctly calling the `eval` (or `Invoke-Expression` for PowerShell) command with the appropriate path and shell flag (`-s`, `-c`, `-f`, or `-w`).

----

# Man Page of `proxy_helper`

## NAME

`proxy_helper` -- helper for constructing proxy environment variables

## SYNOPSIS

    proxy_helper [-c | -s | -f | -w] [-p] [-u <url>]

## DESCRIPTION

The `proxy_helper` utility reads the proxy settings from System Preferences and constructs
the `http_proxy`, `https_proxy`, `ftp_proxy` and `no_proxy` environment variables respectively.

Options:

    -c      Generate C-shell commands on stdout.  This is the default if `$SHELL` ends with "csh".

    -s      Generate Bourne shell commands on stdout.  This is the default if `$SHELL` ends with none of the other supported shells.

    -f      Generate Fish shell commands on stdout.  This is the default if `$SHELL` ends with "fish".

    -w      Generate PowerShell commands on stdout.  This is the default if `$SHELL` ends with "pwsh" or "powershell".

    -p      Enable Proxy Auto-Configuration (PAC) script evaluation.

    -u      Target URL used for PAC script evaluation. If not specified, "https://www.google.com" is used as a default.

The `proxy_helper` utility reads the proxy configuration from the System Preferences,
and prints a one-liner shell script defining `*_proxy` environment variables.

  * `http_proxy` - Generated from the "Web Proxy Server".
  * `https_proxy` - Generated from the "Secure Web Proxy Server". 
  * `ftp_proxy` - Generated from the "FTP Proxy Server".
  * `no_proxy` - Generated from "Bypass proxy settings".

The `no_proxy` variable is generated based on the rules below:

  * If a host matches to the pattern `*.some.domain.name`, then `some.domain.name` is added.
  * If a host matches to a valid IPv4 address, then the host is added as is.
  * If a host matches to a valid IPv6 address, then the host is added after removing square brackets (e.g., `fe80::1`).
  * If a host matches to a valid CIDR subnet notation (IPv4 or IPv6), then the host is added as is (e.g., `192.168.1.0/24` or `fe80::/64`).
  * Ignored otherwise.

The proxy settings are retrieved from the network interface with the highest priority amongst currently active ones.

After you connected to another network environment, you may manually re-run this command to apply new proxy settings.

## USAGE

The `proxy_helper` utility should not be invoked directly.
It is intended only for use by the shell profile.

In your `/etc/profile` for BASH, or `/etc/zprofile` for ZSH, add the following code snippet:

    if [ -x PATH_TO_YOUR_INSTALLATION/proxy_helper ]; then
        eval `PATH_TO_YOUR_INSTALLATION/proxy_helper -s`
    fi

In your `~/.config/fish/config.fish` for Fish, add the following code snippet:

    if test -x PATH_TO_YOUR_INSTALLATION/proxy_helper
        eval (PATH_TO_YOUR_INSTALLATION/proxy_helper -f)
    end

In your profile script for PowerShell, add the following code snippet:

    if (Test-Path PATH_TO_YOUR_INSTALLATION/proxy_helper) {
        PATH_TO_YOUR_INSTALLATION/proxy_helper -w | Invoke-Expression
    }

## AUTHOR

Takuma Watannabe <takumaw@sfo.kuramae.ne.jp>

## SEE ALSO

  * `path_helper(8)`
