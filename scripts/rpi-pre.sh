# Raspberry Pi: the firmware loads from a FAT32 (LBA) partition 1, then boots the kernel from it.
IMAGE_MKFS_BOOT="mkfs.fat -F32 -n RPI-BOOT"
IMAGE_FDISK_OPTS="-H 255 -S 63"
BOOT_PART_TYPE="c"
# Same as Alpine setup-disk on Raspberry Pi.
MKINITFS_FEATURES="base mmc usb ext4"

# Pi do not have hwclock
BOOT_SERVICES=$(echo $BOOT_SERVICES | sed 's/hwclock//g')
BOOT_SERVICES="${BOOT_SERVICES} swclock"
