# proxy_helper

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
and prints a one-liner shell script defining `*_proxy` environmental variables including:

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

In your `/etc/profile` in BASH, or `/etc/zprofile` in ZSH, add the following lines:

    if [ -x PATH_TO_YOUR_INSTALLATION/proxy_helper ]; then
        eval `PATH_TO_YOUR_INSTALLATION/proxy_helper -s`
    fi

## COPYRIGHT

(C)2018 WATANABE Takuma takumaw@sfo.kuramae.ne.jp.

Licence: MIT.

## BUGS

Currently, Proxy Auto-Configuration (PAC) scripts are not supported.
You have to manually specify your proxy servers in the System Preferences.
