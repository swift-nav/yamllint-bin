#!/usr/bin/env bash

set -ex

cargo install pyoxidizer
pyoxidizer build --release

cp build/*/releaes/install/yamllint* .
