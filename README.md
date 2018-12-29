# proxy_helper

(C)2018 WATANABE Takuma takumaw@sfo.kuramae.ne.jp.

Licence: MIT.

## What is this

The `proxy_helper` utility reads the proxy settings from System Preferences and constructs
the `http_proxy`, `https_proxy`, `ftp_proxy` and `no_proxy` environment variables respectively.

    $ proxy_helper -s
    http_proxy="http://YOUR_HTTP_PROXY_SERVER:PORT"; export http_proxy; https_proxy="http://YOUR_HTTPS_PROXY_SERVER:PORT"; export https_proxy; ftp_proxy="http://YOUR_FTP_PROXY_SERVER:PORT"; export ftp_proxy; no_proxy="NO_PROXIES"; export no_proxy;

## How to install

Homebrew tap is available at https://github.com/takumaw/homebrew-proxy_helper.

    brew tap takumaw/proxy_helper
    brew install proxy_helper

Or, you may build a binary from the source. See [INSTALL.md](/INSTALL.md).

## How it works

In your `/etc/profile` for BASH, or `/etc/zprofile` for ZSH, add the following code snippet: 

    if [ -x /usr/local/opt/proxy_helper/libexec/proxy_helper ]; then
        eval `/usr/local/opt/proxy_helper/libexec/proxy_helper -s`
    fi

Change the path to the binary when you install it to another directory (e.g. built from the source.)

You may innstead put the snippet on `~/.bash_profile`, `~/.zshenv` or `~/.zprofile`.

For CSH or TCSH users, put the following code to e.g. `/etc/csh.login`:

    if ( -x /usr/local/opt/proxy_helper/libexec/proxy_helper ) then
        eval `/usr/local/opt/proxy_helper/libexec/proxy_helper -c`
    endif

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


----

# Man Page of `proxy_helper`

## NAME

`proxy_helper` -- helper for constructing proxy environment variables

## SYNOPSIS

    proxy_helper [-c | -s]

## DESCRIPTION

The `proxy_helper` utility reads the proxy settings from System Preferences and constructs
the `http_proxy`, `https_proxy`, `ftp_proxy` and `no_proxy` environment variables respectively.

Options:

    -c      Generate C-shell commands on stdout.  This is the default if SHELL ends with "csh".

    -s      Generate Bourne shell commands on stdout.  This is the default if SHELL does not end with "csh".

The `proxy_helper` utility reads the proxy configuration from the System Preferences,
and prints a one-liner shell script defining `*_proxy` environment variables.

  * `http_proxy` - Generated from the "Web Proxy Server".
  * `https_proxy` - Generated from the "Secure Web Proxy Server". 
  * `ftp_proxy` - Generated from the "FTP Proxy Server".
  * `no_proxy` - Generated from "Bypass proxy settings".

The `no_proxy` variable is generated based on the rules below:

  * If a host matches to the pattern `*.some.domain.name`, then `some.domain.name` is added.
  * If a host matches to the pattern `[0-9]+.[0-9]+.[0-9]+.[0-9]+` (that is, IPv4 address), then the host is added as is.
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

## AUTHOR

Takuma Watannabe <takumaw@sfo.kuramae.ne.jp>

## SEE ALSO

  * `path_helper(8)`

## BUGS

Currently, Proxy Auto-Configuration (PAC) scripts are not supported.
You have to manually specify your proxy servers in the System Preferences.
