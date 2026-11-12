#!/usr/bin/env bash
set -ex

. scripts/env.sh
echo Loadded
print-preset

image-create
image-partation
mount-loop
image-mkfs
mount-root

setup-rootfs
setup-chroot
setup-mkinitfs
setup-kernel
setup-service

setup-conf
setup-user-admin

setup-boot
# bash

# Clean and unmount before compressing, so the archive holds a consistent filesystem.
clean
umount-all

# useless for gz asset
# usefull for upload to ecs, aws, aliyun
# image-shrink
image-gz

# docker-build.sh passes the caller ids so the output is not left owned by root.
if [ -n "${HOST_UID:-}" ]; then chown -R "$HOST_UID:${HOST_GID:-$HOST_UID}" dist; fi
