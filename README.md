# proxy_helper

## NAME

`proxy_helper` -- helper for constructing proxy environment variable

## SYNOPSIS

    proxy_helper [-c | -s]

## DESCRIPTION

The `proxy_helper` utility reads the proxy settings from System Preferences and constructs
the `http_proxy`, `https_proxy`, `ftp_proxy` and `no_proxy` environment variables respectively.

Options:

    -c      Generate C-shell commands on stdout.  This is the default if SHELL ends with "csh".

    -s      Generate Bourne shell commands on stdout.  This is the default if SHELL does not end with "csh".

## NOTE

The `proxy_helper` utility should not be invoked directly.
It is intended only for use by the shell profile.

## COPYRIGHT

(C)2018 WATANABE Takuma takumaw@sfo.kuramae.ne.jp.

Licence: MIT.
