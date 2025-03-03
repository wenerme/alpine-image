#!/bin/bash

[ -z "$VER" ] && {
  VER=$(curl -sf https://alpinelinux.org/releases.json | jq '.release_branches[1].releases[0].version' -r)
  echo $VER > ../VERSION
}

CHECKSUM=$(curl -sf https://mirrors.tuna.tsinghua.edu.cn/alpine/latest-stable/releases/x86_64/alpine-virt-$VER-x86_64.iso.sha256 | awk '{print $1}')

echo "VER=$VER
CHECKSUM=$CHECKSUM
"

yq -i ".checksums.\"alpine-virt-$VER-x86_64.iso\"=\"$CHECKSUM\"" checksums.auto.pkrvars.json
yq -i '.checksums |= sort_keys(.)' checksums.auto.pkrvars.json
