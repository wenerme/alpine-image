#!/usr/bin/env bash

QUIET=1 . scripts/preset.sh
. scripts/docker-run.sh

DOCKER_MODE=i DOCKER_CMD="env verbose=1 profile=${profile} conf=${conf} FLAVOR=${FLAVOR} bash --rcfile scripts/env.sh -c " docker-run "scripts/get-root-uuid.sh $@"
