#!/bin/bash
set -ex

[ -e alpine.img ] || truncate -s 2G alpine.img
losetup -l | grep /dev/loop0 || losetup --partscan /dev/loop0 alpine.img
blkid /dev/loop0p1 /dev/loop0p2 || cat <<CONF | sfdisk --wipe always /dev/loop0
label: dos
unit: sectors
sector-size: 512

/dev/loop0p1 : size=+128M, type=83, bootable
/dev/loop0p2 : type=83
CONF

blkid /dev/loop0p1 | grep TYPE || mkfs.ext4 /dev/loop0p1
blkid /dev/loop0p2 | grep TYPE || mkfs.ext4 /dev/loop0p2

findmnt /mnt || mount /dev/loop0p2 /mnt
mkdir -p /mnt/boot
findmnt /mnt/boot || mount /dev/loop0p1 /mnt/boot

[ -e /mnt/etc/os-release ] || setup-disk -m sys -o artifacts/sysfs.apkvol.tar.gz -s 0 -v -k ${flavor:-lts} /mnt
[ -e /mnt/boot/extlinux.conf ] || apk --root /mnt add syslinux

dd bs=440 conv=notrunc count=1 if=/usr/share/syslinux/mbr.bin of=/dev/loop0


echo Done
