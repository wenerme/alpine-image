docker-run(){
  docker run --rm -${DOCKER_MODE:-it} \
    --privileged -v /dev:/dev:ro \
    -v "$PWD/cache/apk:/etc/apk/cache" \
    -v "$PWD":/build -w /build \
    $DOCKER_OPTS --name builder wener/alpine-image-builder $DOCKER_CMD "$@"
}
