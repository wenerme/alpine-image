#!/usr/bin/env bash
set -ex

docker run -v --privileged -v /dev:/dev:ro \
  -v "$PWD":/build -w /build \
  -v "$PWD/cache/apk/${ARCH:-x86_64}:/etc/apk/cache" \
  wener/base ./check-binfmt.sh
