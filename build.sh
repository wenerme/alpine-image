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
setup-kernel
setup-service

setup-conf
setup-user-admin

setup-boot
# bash

# useless for gz asset
# usefull for upload to ecs, aws, aliyun
# image-shrink
image-gz

# umount-all
losetup -D

# cleanup
mount-all
clean
umount-all
