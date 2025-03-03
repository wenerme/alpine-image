#!/bin/sh
set -eux
echo "Building ${ALPINE_VER} using ${ALPINE_MIRROR}"
echo "${ALPINE_MIRROR}/v${ALPINE_VER}/main" > /etc/apk/repositories
echo "${ALPINE_MIRROR}/v${ALPINE_VER}/community" >> /etc/apk/repositories
rc-update add networking
apk upgrade -a
ERASE_DISKS=/dev/vda setup-disk -m sys -s 0 -k "${ALPINE_FLAVOR}" /dev/vda
echo "Installed Alpine Linux ${ALPINE_VER} to /dev/vda"
