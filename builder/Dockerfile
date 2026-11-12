# Image builder used by docker-build.sh: loop devices, partitioning, chroot and compression tools.
FROM alpine:3.24

RUN apk add --no-cache \
    bash \
    blkid \
    coreutils \
    dosfstools \
    e2fsprogs \
    file \
    findmnt \
    losetup \
    mount \
    pigz \
    qemu-aarch64 \
    qemu-arm \
    sfdisk \
    syslinux \
    umount \
    util-linux-misc \
    wget
