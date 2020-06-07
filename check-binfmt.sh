#!/usr/bin/env bash
set -ex

apk add wget

miniroot(){
  local arch=$1
  local ver=$2
  local url="https://mirrors.tuna.tsinghua.edu.cn/alpine/v${ver%%.[0-9]}/releases/${arch}/alpine-minirootfs-${ver}-${arch}.tar.gz"
  echo downloading $url
  wget -qcN $url -P cache
  mkdir -p arch/${arch}/root
  tar zxf cache/alpine-minirootfs-${ver}-${arch}.tar.gz -C arch/${arch}/root

  cp arch/${arch}/root/lib/ld-musl-${arch}.so.1 /lib
}

miniroot armhf 3.12.0
miniroot aarch64 3.12.0

apk add qemu-arm qemu-aarch64

qemu-arm arch/armhf/root/bin/busybox uname -a
arch/armhf/root/bin/busybox uname -a
chroot arch/armhf/root uname -a

qemu-aarch64 arch/aarch64/root/bin/busybox uname -a
arch/aarch64/root/bin/busybox uname -a
chroot arch/aarch64/root uname -a
