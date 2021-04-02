#!/bin/bash
set -ex

apk add cryptsetup util-linux coreutils shadow sudo
# reset
umount -R /mnt || true
losetup -D
[ -e /dev/mapper/cryptroot ] && cryptsetup close cryptroot

: ${IMAGE_SIZE:=2G}
: ${TARGET_IMG:=alpine.img}
rm -f $TARGET_IMG
truncate -s $IMAGE_SIZE "$TARGET_IMG"


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

#
: ${PASSWORD:=$(uuidgen | tr -d '\n')}
[ -f key.txt ] || {
  echo -n $PASSWORD > key.txt
}

yes | cryptsetup -y -v luksFormat $ROOT_DEV -d key.txt
# docker do not have this module
# modeprobe dm_mod
cryptsetup open $ROOT_DEV cryptroot -d key.txt

# todo
# : ${ROOT_MNT:="/mnt"}
ROOT_MNT=/mnt

mkfs.ext4 /dev/mapper/cryptroot
mount /dev/mapper/cryptroot /mnt

mkfs.ext4 $BOOT_DEV
mkdir -p /mnt/boot
mount $BOOT_DEV /mnt/boot

: ${KERNAL_FLAVOR:=virt}
#
setup-disk -m sys -o artifacts/sysfs.apkvol.tar.gz -s 0 -v -k $KERNAL_FLAVOR $ROOT_MNT
apk --root $ROOT_MNT add syslinux

# boot
apk --root /mnt add cryptsetup
echo 'features="ata base ide scsi usb virtio ext4 cryptsetup cryptkey"' > /mnt/etc/mkinitfs/mkinitfs.conf
mkinitfs -c /mnt/etc/mkinitfs/mkinitfs.conf -i /mnt/usr/share/mkinitfs/initramfs-init -b /mnt/ $(ls /mnt/lib/modules/)

# add cryptroot
# cryptroot=UUID=<UUID> cryptdm=cryptroot
# other options - https://github.com/alpinelinux/mkinitfs/blob/961726b6aeb8e12176009675f22ed0ffc2b26e14/initramfs-init.in#L443-L482
sed -i -r "s/^(default_kernel_opts)=\"([^\"]*)\"/\1=\"\2 cryptroot=UUID=$(blkid ${ROOT_DEV} -o value | head -n 1) cryptdm=cryptroot\"/" /mnt/etc/update-extlinux.conf
chroot /mnt update-extlinux

umount -R $ROOT_MNT
cryptsetup close cryptroot

dd bs=440 conv=notrunc count=1 if=/usr/share/syslinux/mbr.bin of=${LOOP_DEV}
losetup -d $LOOP_DEV

cat <<VARS | tee vars.sh
LOOP_DEV=${LOOP_DEV}
BOOT_DEV=${BOOT_DEV}
ROOT_DEV=${ROOT_DEV}

ROOT_MNT=${ROOT_MNT}
TARGET_IMG=${TARGET_IMG}
KEYFILE=./key.txt
VARS
