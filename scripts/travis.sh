#!/usr/bin/env bash

set -ex

if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
    sudo apt install libyaml-dev
fi

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    brew install libyaml
fi

cargo install pyoxidizer
pyoxidizer build --release

cp build/*/release/install/yamllint* .
