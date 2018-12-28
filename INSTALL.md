# INSTALL
## Prerequisites

  * Xcode
  * automake
  * autoconf

## Generate Makefile

    aclocal
    automake --add-missing
    autoconf

## Build and Install

    ./configure
    make install
