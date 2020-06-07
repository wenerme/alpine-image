# AlpineLinux pre-build disk images

![Build Image](https://github.com/wenerme/alpine-image/workflows/Build%20Image/badge.svg)

> ⚠️
>
> Default user:password is `admin:admin`

## How to use

```bash
# All release https://github.com/wenerme/alpine-image/releases
# latest alpine-virt-3.12.img.gz
file=alpine-virt-3.12.img.gz
download_url=$(curl -s https://api.github.com/repos/wenerme/alpine-image/releases/latest | grep $file | sed -rn 's/.*?(https[^"]+).*/\1/p')
curl -LOC- $download_url
gzip -dk $file
# start by using qemu
qemu-system-x86_64 -hda ${file%%.gz}

# write to disk or usb
# macOS use rdisk
sudo dd if=${file%%.gz} of=/dev/rdisk2 status=progress bs=64M
# Linux use sdx
sudo dd if=${file%%.gz} of=/dev/sdb status=progress bs=64M

# now you can boot from the external storage
```

## Images
* alpine-$FLAVOR-$VERSION-$ARCH.img
  * FLAVOR
    * virt
      * for cloud env - aws, gce, aliyun
      * for vm - qemu, libvirt
      * linux without firmware
    * ltx - Linux 5.14
      * with firmwares
      * can run on phy machines
    * rpi
      * Raspberry PI
      * armhf - PiZero Pi 1
      * armv7 - Pi 2, Pi 3
      * aarch64 - Pi 3, Pi 4
  * ARCH
    * x86_64
    * armhf - armv6
    * aarch64 - armv8 - arm64

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

