#!/usr/bin/env bash

set -ex

cargo install pyoxidizer

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    cp pyoxidizer.bzl.macos pyoxidizer.bzl
fi

pyoxidizer build --release

cp build/*/releaes/install/yamllint* .
