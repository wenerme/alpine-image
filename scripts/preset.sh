
: "${ALPINE_RELEASE:=3.12.0}"
: "${ALPINE_VERSION:=${ALPINE_RELEASE%.*}}"
: "${ALPINE_BRANCH:=v${ALPINE_VERSION}}"
: "${ALPINE_MIRROR:=https://mirrors.aliyun.com/alpine}"

: ${ARCH:=x86_64}
: ${FLAVOR:=lts}

: "${TARGET_IMG_PREFIX:=alpine-}"
: "${TARGET_IMG:=${TARGET_IMG_PREFIX}${ARCH}-${FLAVOR}.img}"

: "${TZ:=Asia/Shanghai}"

: ${MNT:=/alpine}

# detech qemu-arch
if [ -n $QEMU_ARCH ]; then
QEMU_ARCH=$(qemu-arch-detect $ARCH)
fi

mirror_base=${ALPINE_MIRROR}/${ALPINE_BRANCH}
rootfs_url="${ALPINE_MIRROR}/${ALPINE_BRANCH}/releases/${ARCH}/alpine-minirootfs-${ALPINE_RELEASE}-${ARCH}.tar.gz"

print-preset(){
  echo "==============================
Alpine ${ARCH} ${ALPINE_RELEASE}
  mirror ${mirror_base}
  rootfs ${rootfs_url}
  image ${TARGET_IMG}
  qemu-arch ${QEMU_ARCH}
=============================="
}
