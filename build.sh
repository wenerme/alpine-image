#!/usr/bin/env bash
set -x

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
setup-kernel
setup-service

setup-conf
setup-user-admin

setup-boot
# bash

image-shrink
image-gz

# umount-all
losetup -D
