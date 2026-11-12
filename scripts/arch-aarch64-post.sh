# syslinux is x86 only; aarch64 images boot with a standalone GRUB EFI binary on the ESP.
setup-boot(){
  local root boot
  root=$(blkid -s UUID -o value "$ROOT_DEV")
  boot=$(blkid -s UUID -o value "$BOOT_DEV")
  local kernel_opts=${KERNEL_OPTS:-"modules=sd-mod,usb-storage,ext4 rootfstype=ext4 quiet console=tty0 console=ttyAMA0,115200"}

  # Used when grub-mkconfig regenerates the config on a booted system after a grub upgrade.
  mkdir -p "$MNT/etc/default"
  cat > "$MNT/etc/default/grub" <<GRUB
GRUB_TIMEOUT=2
GRUB_DISABLE_SUBMENU=y
GRUB_DISABLE_RECOVERY=true
GRUB_CMDLINE_LINUX_DEFAULT="${kernel_opts}"
GRUB

  chmnt apk add -q e2fsprogs dosfstools
  # The grub trigger runs grub-mkconfig against the build host; the config is written below instead.
  chmnt apk add -q --no-scripts grub grub-efi

  mkdir -p "$MNT/boot/EFI/BOOT" "$MNT/boot/grub"
  # The prefix has no device, so GRUB reads /grub from the partition it was loaded from.
  chmnt grub-mkimage -O arm64-efi -p /grub -o /boot/EFI/BOOT/BOOTAA64.EFI \
    part_msdos part_gpt fat ext2 normal linux configfile search search_fs_uuid gzio echo test efi_gop

  cat > "$MNT/boot/grub/grub.cfg" <<CFG
set default=0
set timeout=2

menuentry "Alpine Linux ${ALPINE_RELEASE} ${FLAVOR}" {
  search --no-floppy --fs-uuid --set=root ${boot}
  linux /vmlinuz-${FLAVOR} root=UUID=${root} ${kernel_opts}
  initrd /initramfs-${FLAVOR}
}
CFG

  cat > "$MNT/etc/fstab" <<FSTAB
UUID=${root}  /      ext4  rw,relatime                         0 1
UUID=${boot}  /boot  vfat  rw,relatime,fmask=0022,dmask=0022  0 2
FSTAB
}
