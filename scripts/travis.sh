#!/usr/bin/env bash

set -ex

if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then

  docker build --tag musl-builder -f Dockerfile.linux .
  docker run --name musl-builder-run musl-builder

  build_dir=build/x86_64-unknown-linux-musl/release/install
  mkdir -p $build_dir

  docker cp musl-builder-run:/home/rust/src/$build_dir/yamllint \
    $build_dir/yamllint

  docker rm musl-builder-run
  docker rmi musl-builder

elif [[ "$TRAVIS_OS_NAME" == "osx" ]]; then

  RUSTFLAGS="-C link-arg=-L/usr/local/opt/libyaml/lib"

  cargo install pyoxidizer
  pyoxidizer build --release

  cp build/*/release/install/yamllint* .

elif [[ "$TRAVIS_OS_NAME" == "windows" ]]; then

  cargo install pyoxidizer
  pyoxidizer build --release

  cp build/*/release/install/yamllint* .
fi
