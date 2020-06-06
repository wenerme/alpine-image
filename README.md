# AlpineLinux pre-build disk images


## Dev

```bash
# build using privileged - loopdev
FLAVOR=virt ./docker-build.sh
# enter shell for testing
FLAVOR=virt ./test.sh

# Normal boot
# macOS -accel hvf
qemu-system-x86_64 -accel hvf -hda alpine-x86_64-virt.img
# testing boot
qemu-system-x86_64 -accel hvf -hda alpine-x86_64-virt.img \
  -kernel vmlinuz-virt -initrd initramfs-virt

# testing cmdline
ROOT_UUID=$(./get-root-uuid.sh alpine-x86_64-virt.img)
#
qemu-system-x86_64 -accel hvf -hda alpine-x86_64-virt.img \
  -kernel vmlinuz-virt -initrd initramfs-virt \
  -append "root=UUID=$ROOT_UUID modules=sd-mod,usb-storage,ext4 nomodeset quiet rootfstype=ext4"

# MBR fix
dd bs=440 conv=notrunc count=1 if=/usr/share/syslinux/mbr.bin of=/dev/loop0
# dd bs=440 conv=notrunc count=1 if=mbr.bin of=alpine-x86_64-virt.img
```

