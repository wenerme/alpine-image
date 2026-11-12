#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

: "${ARCH:=x86_64}"
: "${FLAVOR:=lts}"
: "${ALPINE_RELEASE:=$(< "$repo_root/builds/VERSION")}"
: "${ALPINE_MIRROR:=https://mirrors.aliyun.com/alpine}"
: "${BUILDER_IMAGE:=alpine-image-builder:local}"
: "${BUILDER_NAME:=builder-${ARCH}-${FLAVOR}-$$}"
: "${IMAGE_SIZE:=2G}"
: "${verbose:=1}"
: "${profile:=$FLAVOR}"
: "${conf:=}"

. "$repo_root/scripts/docker-run.sh"

# The default builder is built from builder/Dockerfile; set BUILDER_IMAGE to use a prebuilt one.
if [ "$BUILDER_IMAGE" = alpine-image-builder:local ]; then
  docker build -q -t "$BUILDER_IMAGE" "$repo_root/builder" >/dev/null
fi

DOCKER_MODE=i
BUILDER_IMAGE="$BUILDER_IMAGE"
BUILDER_NAME="$BUILDER_NAME"
DOCKER_ROOT="$repo_root"
DOCKER_ARGS=(
  env
  "verbose=$verbose"
  "profile=$profile"
  "conf=$conf"
  "ALPINE_RELEASE=$ALPINE_RELEASE"
  "ALPINE_MIRROR=$ALPINE_MIRROR"
  "IMAGE_SIZE=$IMAGE_SIZE"
  "FLAVOR=$FLAVOR"
  "ARCH=$ARCH"
  ./build.sh
)
docker-run
