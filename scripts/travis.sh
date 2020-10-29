#!/usr/bin/env bash

set -ex

if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then

  docker build --tag musl-builder -f Dockerfile.linux .
  docker run --name musl-builder-run musl-builder

  build_dir=build/x86_64-unknown-linux-musl/release/install
  mkdir -p dist

  docker cp musl-builder-run:/home/rust/src/$build_dir/yamllint \
    dist/yamllint

  docker rm musl-builder-run
  docker rmi musl-builder

elif [[ "$TRAVIS_OS_NAME" == "osx" ]]; then

  export RUSTFLAGS="-C link-arg=/usr/local/opt/libyaml/lib/libyaml.a"

  cargo install pyoxidizer
  pyoxidizer build --release

  mkdir -p dist
  cp build/*/release/install/yamllint dist/yamllint

elif [[ "$TRAVIS_OS_NAME" == "windows" ]]; then

  cargo install pyoxidizer
  pyoxidizer build --release

  mkdir -p dist
  cp build/*/release/install/yamllint* dist
fi
