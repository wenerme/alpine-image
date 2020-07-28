#!/bin/bash
set -ex

[ -f vars.sh ] && source vars.sh

: ${IMAGE_SIZE:=2G}
: ${TARGET_IMG:=alpine.img}

[ -f $TARGET_IMG ] || {
  truncate -s $IMAGE_SIZE "$TARGET_IMG"
}

: ${LOOP_DEV:="/dev/loop0"}
: ${BOOT_DEV:="/dev/loop0p1"}
: ${ROOT_DEV:="/dev/loop0p2"}

LOOP_DEV=$(losetup --partscan --show --find "${TARGET_IMG}")
BOOT_DEV="$LOOP_DEV"p1
ROOT_DEV="$LOOP_DEV"p2

cat <<CONF | sfdisk --wipe always ${LOOP_DEV}
label: dos
unit: sectors
sector-size: 512

${BOOT_DEV} : size=+128M, type=83, bootable
${ROOT_DEV} : type=83
CONF

mkfs.${BOOT_FS:-ext4} "$BOOT_DEV"
mkfs.${ROOT_FS:-ext4} "$ROOT_DEV"

: ${ROOT_MNT:="/mnt"}

mkdir -p $ROOT_MNT
mount --make-private "$ROOT_DEV" $ROOT_MNT
mkdir -p $ROOT_MNT/boot
mount --make-private "$BOOT_DEV" $ROOT_MNT/boot

cat <<VARS | tee >> vars.sh
LOOP_DEV=${LOOP_DEV}
BOOT_DEV=${BOOT_DEV}
ROOT_DEV=${ROOT_DEV}

ROOT_MNT=${ROOT_MNT}
TARGET_IMG=${TARGET_IMG}
VARS

setup-disk -m sys -o artifacts/sysfs.apkvol.tar.gz -s 0 -v -k virt $ROOT_MNT
apk --root $ROOT_MNT add syslinux

umount -R $ROOT_MNT

dd bs=440 conv=notrunc count=1 if=/usr/share/syslinux/mbr.bin of=${LOOP_DEV}
losetup -d $LOOP_DEV
