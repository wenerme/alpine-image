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
    umount \
    util-linux-misc \
    wget

# syslinux only exists on x86; arm hosts (e.g. Apple Silicon) can still build arm and RPi images.
RUN case "$(apk --print-arch)" in x86*) apk add --no-cache syslinux ;; esac
