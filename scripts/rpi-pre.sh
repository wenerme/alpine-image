IMAGE_MKFS_BOOT="mkfs.fat -F32"
IMAGE_FDISK_OPTS="-H 255 -S 63"
# win fat
BOOT_PART_TYPE="c"
# Same as Alpine setup-disk on Raspberry Pi.
MKINITFS_FEATURES="base mmc usb ext4"
