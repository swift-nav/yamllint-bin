#!/usr/bin/env bash

set -ex

if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
    sudo apt-get install -y libyaml-dev
fi

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    brew install libyaml
fi

cargo install --git https://github.com/indygreg/PyOxidizer.git --rev b3c1833a6185cd4379ab673c86975b44daa07b66 pyoxidizer

pyoxidizer build --release

cp build/*/release/install/yamllint* .
