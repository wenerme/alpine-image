# aarch64 boots through UEFI: the boot partition is a FAT32 EFI System Partition.
BOOT_PART_TYPE=ef
IMAGE_MKFS_BOOT="mkfs.fat -F32"
# Same as Alpine setup-disk on aarch64, which adds phy.
MKINITFS_FEATURES="ata base ide scsi usb virtio ext4 nvme mmc phy"
