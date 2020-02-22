#!/bin/sh

$VCS_HOME/bin/vcs -full64 -cpp g++-5 -cc gcc-5 -LDFLAGS -Wl,--no-as-needed $*