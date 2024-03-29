#!/usr/bin/env bash

set -ex

version=$(git describe --tags)

if [[ "$RUNNER_OS" == "Linux" ]]; then

  rm -f PyOxidizer/yamllint

  mkdir -p PyOxidizer/target/release
  mkdir -p dist

  (cd PyOxidizer && ln -sf ../yamllint .)

  docker build --tag musl-builder -f Dockerfile.linux .

  docker run --rm --name musl-builder-run -v "$PWD:/work" musl-builder \
    sh -c "sudo chown -R rust:rust . && \
           cd PyOxidizer && \
           cargo build --release && \
           cargo run --release -- build \
             --target-triple x86_64-unknown-linux-musl --release --path yamllint"

  sudo chown -R "$(id -u):$(id -g)" .

  build_dir=build/x86_64-unknown-linux-musl/release/install
  cp $build_dir/yamllint dist/yamllint-linux.bin

  strip dist/yamllint-linux.bin

  curl -sSL https://github.com/upx/upx/releases/download/v3.96/upx-3.96-amd64_linux.tar.xz | tar -xvJf -

  rm -f dist/yamllint-linux
  ./upx-3.96-amd64_linux/upx -9 dist/yamllint-linux.bin -o dist/yamllint

  tar -C dist -czf "yamllint-$version-linux.tgz" yamllint

  echo "yamllint-$version-linux.tgz" >release-archive.filename

elif [[ "$RUNNER_OS" == "macOS" ]]; then

  export RUSTFLAGS="-C link-arg=/usr/local/opt/libyaml/lib/libyaml.a"

  (cd PyOxidizer; cargo install --path ./pyoxidizer)
  pyoxidizer build --release

  mkdir -p dist
  cp build/*/release/install/yamllint dist/yamllint-macos.bin

  strip dist/yamllint-macos.bin

  brew install upx

  rm -f dist/yamllint-macos
  upx -9 dist/yamllint-macos.bin -o dist/yamllint

  tar -C dist -czf "yamllint-$version-macos.tgz" yamllint

  echo "yamllint-$version-macos.tgz" >release-archive.filename

elif [[ "$RUNNER_OS" == "Windows" ]]; then

  (cd PyOxidizer; cargo install --path ./pyoxidizer)
  pyoxidizer build --release

  mkdir -p dist
  cp build/*/release/install/yamllint.exe dist/yamllint-windows-bin.exe

  curl -LO https://github.com/upx/upx/releases/download/v3.96/upx-3.96-win64.zip
  7z x upx-3.96-win64.zip

  rm -f dist/yamllint-windows.exe
  ./upx-3.96-win64/upx.exe -9 dist/yamllint-windows-bin.exe -o dist/yamllint.exe

  cd dist
  7z a -tzip "../yamllint-$version-windows.zip" yamllint.exe
  cd ..

  echo "yamllint-$version-windows.zip" >release-archive.filename
fi
