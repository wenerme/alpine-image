# aarch64 boots through UEFI: the boot partition is a FAT32 EFI System Partition.
BOOT_PART_TYPE=ef
BOOT_SIZE=256MB
IMAGE_MKFS_BOOT="mkfs.fat -F32"
