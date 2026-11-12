#!/bin/bash
set -eu

: "${FLAVOR:=${flavor:-virt}}"

[ -z "${VER:-}" ] && {
  VER=$(curl -sf https://alpinelinux.org/releases.json | jq '.release_branches[1].releases[0].version' -r)
  printf '%s\n' "$VER" > ../VERSION
}

case "$FLAVOR" in
  virt)
    iso_flavor=virt
    ;;
  lts|standard)
    iso_flavor=standard
    ;;
  *)
    echo "Unsupported flavor: $FLAVOR (expected virt, lts, or standard)" >&2
    exit 1
    ;;
esac
iso="alpine-$iso_flavor-$VER-x86_64.iso"
branch=${VER%.*}
checksum_url="https://mirrors.tuna.tsinghua.edu.cn/alpine/v$branch/releases/x86_64/$iso.sha256"
CHECKSUM=$(curl -sf "$checksum_url" | awk 'NR == 1 {print $1}')
[ -n "$CHECKSUM" ]

echo "VER=$VER
CHECKSUM=$CHECKSUM
"

yq -i ".checksums.\"$iso\"=\"$CHECKSUM\"" checksums.auto.pkrvars.json
yq -i '.checksums |= sort_keys(.)' checksums.auto.pkrvars.json
