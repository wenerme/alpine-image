docker-run(){
  : "${BUILDER_IMAGE:=wener/alpine-image-builder}"
  : "${BUILDER_NAME:=builder}"
  local docker_root=${DOCKER_ROOT:-$PWD}
  local -a command_args=()
  if declare -p DOCKER_ARGS >/dev/null 2>&1; then
    command_args=("${DOCKER_ARGS[@]}")
  elif [ -n "${DOCKER_CMD:-}" ]; then
    read -r -a command_args <<< "$DOCKER_CMD"
  fi
  mkdir -p "$docker_root/cache/apk/${ARCH:-x86_64}"
  docker run --rm -${DOCKER_MODE:-it} \
    --privileged -v /dev:/dev:ro \
    -v "$docker_root/cache/apk/${ARCH:-x86_64}:/etc/apk/cache" \
    -v "$docker_root":/build -w /build \
    ${DOCKER_OPTS:-} --name "$BUILDER_NAME" "$BUILDER_IMAGE" \
    "${command_args[@]}" "$@"
}
