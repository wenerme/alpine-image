# AlpineLinux pre-build disk images

![Build Image](https://github.com/wenerme/alpine-image/workflows/Build%20Image/badge.svg)

```bash
# building images

# docker based building
# flavor=virt format=qcow2
make images/virt/alpine.qcow2
# flavor=lts format=raw
make images/lts/alpine.raw

# packer based building
cd builds/alpine
efi=1 flavor=lts format=raw make
```

> pre-build disk image can be download from [releases](https://github.com/wenerme/alpine-image/releases)

**Features**

- Minimal build
- Raw disk image
  - default to 2G
    - [OPTIONAL] can shrink image
- Auto build - based on GitHub Actions

> ⚠️
>
> Default user:password is `admin:admin` or `root:root`

## Directory

- `builds/`
  - `alpine/`
    - packer based base image builder
  - `sysfs.apkvol/`
    - build sysfs.apkvol for later installer
- `scripts/`
  - alpine.pkr.hcl
    - standard alpine installation
      - version = 3.12.0
      - mirror = https://mirrors.aliyun.com/alpine
      - flavor = virt, lts
      - format = qcow2
      - size = 40G
      - accel = hvf (macOS), kvm, none
- `artifacts/` - prebuild apkvol, makes install predictable, cleaner, faster
  - sysfs.apkvol.tar.gz
    - build by sysfs
    - user `root:root`
    - dns `114.114.114.114`
    - service sshd, acpid, ntpd
    - extra service - haveged
      - highly recommanded for virt
    - setup timezone(Asia/Shanghai), keymap
  - rootfs.apkvol.tar.gz
    - minimal apkvol

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
diskutil unmountdisk rdisk2
sudo dd if=${file%%.gz} of=/dev/rdisk2 of=/dev/rdisk2 conv=sparse status=progress bs=128MB
# Linux use sdx
sudo dd if=${file%%.gz} of=/dev/sdb conv=sparse status=progress bs=128MB

# now you can boot from the external storage
```

## Images

- alpine-$FLAVOR-$VERSION-$ARCH.img
  - FLAVOR
    - virt
      - for cloud env - aws, gce, aliyun
      - for vm - qemu, libvirt
      - linux without firmware
    - ltx - Linux 5.14
      - with firmwares
      - can run on phy machines
    - rpi
      - Raspberry PI
      - armhf - PiZero Pi 1
      - armv7 - Pi 2, Pi 3
      - aarch64 - Pi 3, Pi 4
  - ARCH
    - x86_64
    - armhf - armv6
    - aarch64 - armv8 - arm64

## Troubleshoting

## flash to disk under macOS

```bash
# which disk to flush to
diskutil list

DISK=disk3
diskutil umountdisk $DISK

sudo dd if=dist/alpine-lts-3.15.0-x86_64-efi.raw of=/dev/r$DISK conv=sparse status=progress bs=128MB

diskutil eject $DISK
```

### can not boot

using qemu with kernel

### qemu with knernel can boot but can not direct boot

fixing boot or mbr

## Check binfmt works

```bash
docker run -v --privileged -v /dev:/dev:ro \
  -v "$PWD":/build -w /build \
  -v "$PWD/cache/apk/${ARCH:-x86_64}:/etc/apk/cache" \
  wener/base ./check-binfmt.sh
```

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

# Local Playground
docker run --rm -it \
  --privileged -v /dev:/dev:ro \
  -v "$PWD/cache/apk/${ARCH:-x86_64}:/etc/apk/cache" \
  -v "$PWD":/build -w /build \
  --name builder wener/alpine-image-builder
```

## Dev Pi

```bash
curl -O https://mirrors.tuna.tsinghua.edu.cn/alpine/v3.12/releases/aarch64/alpine-rpi-3.12.0-aarch64.tar.gz
mkdir -p aarch64/rpi
tar zxf alpine-rpi-3.12.0-aarch64.tar.gz -C aarch64/rpi


ARCH=aarch64 FLAVOR=rpi ./docker-build.sh

# aarch64 RPi 3B
# Keybord and network seems not working
#
# cmdline for stdio
# console=ttyAMA0,115200 kgdboc=ttyAMA0,115200 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait
# cmdline for pi
# dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait
# dtbs
# bcm2710-rpi-3-b.dtb bcm2837-rpi-3-b.dtb
qemu-system-aarch64 -M raspi3 \
  -append "console=ttyAMA0,115200 kgdboc=ttyAMA0,115200 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait" \
  -serial stdio \
  -dtb aarch64/rpi/bcm2837-rpi-3-b.dtb \
  -kernel aarch64/rpi/boot/vmlinuz-rpi -initrd aarch64/rpi/boot/initramfs-rpi \
  -sd alpine-aarch64-rpi.img

# armhf RPi 3B
wget -qcN https://mirrors.tuna.tsinghua.edu.cn/alpine/v3.12/releases/armhf/alpine-rpi-3.12.0-armhf.tar.gz
mkdir -p armhf/rpi
tar zxf alpine-rpi-3.12.0-armhf.tar.gz -C armhf/rpi

qemu-system-arm -M raspi2 \
  -append "console=ttyAMA0,115200 kgdboc=ttyAMA0,115200 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait" \
  -serial stdio \
  -dtb armhf/rpi/bcm2710-rpi-2-b.dtb \
  -kernel armhf/rpi/boot/vmlinuz-rpi2 -initrd armhf/rpi/boot/initramfs-rpi2 \
  -sd alpine-armhf-rpi.img
```

## Roadmap

- more arch
  - x390
- uboot booting non x86

## Local builds

```bash
ARCH=armhf FLAVOR=rpi ./docker-build.sh
ARCH=aarch64 FLAVOR=rpi ./docker-build.sh
FLAVOR=virt ./docker-build.sh
FLAVOR=lts ./docker-build.sh
```

# Seealso

- [knoopx/alpine-raspberry-pi](https://github.com/knoopx/alpine-raspberry-pi)
