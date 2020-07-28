#!/usr/bin/env bash

. scripts/functions.sh
. scripts/utils.sh
. scripts/preset.sh

. scripts/docker-run.sh

# env passthrough
DOCKER_MODE=i DOCKER_CMD="env verbose=1 profile=${profile} conf=${conf} FLAVOR=${FLAVOR} ARCH=${ARCH} ./build.sh" docker-run
