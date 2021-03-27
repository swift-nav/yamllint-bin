#!/usr/bin/env bash

set -ex

if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then

  docker build --tag musl-builder -f Dockerfile.linux .
  docker run --name musl-builder-run musl-builder

  build_dir=build/x86_64-unknown-linux-musl/release/install
  mkdir -p dist

  docker cp musl-builder-run:/home/rust/src/$build_dir/yamllint \
    dist/yamllint-linux.bin

  strip dist/yamllint-linux.bin

  curl -sSL https://github.com/upx/upx/releases/download/v3.96/upx-3.96-amd64_linux.tar.xz | tar -xvJf -

  rm -f dist/yamllint-linux
  ./upx-3.96-amd64_linux/upx -9 dist/yamllint-linux.bin -o dist/yamllint-linux

  docker rm musl-builder-run
  docker rmi musl-builder

elif [[ "$TRAVIS_OS_NAME" == "osx" ]]; then

  export RUSTFLAGS="-C link-arg=/usr/local/opt/libyaml/lib/libyaml.a"

  cargo install --version 0.9.0 pyoxidizer
  pyoxidizer build --release

  mkdir -p dist
  cp build/*/release/install/yamllint dist/yamllint-macos.bin

  strip dist/yamllint-macos.bin

  brew install upx

  rm -f dist/yamllint-macos
  upx -9 dist/yamllint-macos.bin -o dist/yamllint-macos

elif [[ "$TRAVIS_OS_NAME" == "windows" ]]; then

  cargo install --version 0.9.0 pyoxidizer
  pyoxidizer build --release

  mkdir -p dist
  cp build/*/release/install/yamllint.exe dist/yamllint-windows-bin.exe

  curl -LO https://github.com/upx/upx/releases/download/v3.96/upx-3.96-win64.zip
  7z x upx-3.96-win64.zip

  rm -f dist/yamllint-windows.exe
  ./upx-3.96-win64/upx.exe -9 dist/yamllint-windows-bin.exe -o dist/yamllint-windows.exe
fi
