#!/usr/bin/env bash

set -ex

cargo install pyoxidizer
pyoxidizer run --release

cp build/*/releaes/install/yamllint* .
