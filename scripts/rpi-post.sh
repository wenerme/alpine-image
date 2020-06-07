
# Pi do not have hwclock
BOOT_SERVICES=$(echo $BOOT_SERVICES | sed 's/hwclock//g')
BOOT_SERVICES="${BOOT_SERVICES} swclock"

setup-kernel(){
  chmnt apk add -q linux-rpi
  # https://pkgs.alpinelinux.org/packages?name=linux-rpi*&branch=v3.12
  if [ "aarch64" = "$ARCH" ]; then chmnt apk add -q linux-rpi4; fi
  if [ "armv7" = "$ARCH" ]; then chmnt apk add -q linux-rpi2 linux-rpi4; fi
  if [ "armhf" = "$ARCH" ]; then chmnt apk add -q linux-rpi2; fi
}

setup-boot(){
  chmnt apk add dosfstools

local config="
disable_splash=1
boot_delay=0

kernel=vmlinuz-rpi
initramfs initramfs-rpi

"

if [ -f $MNT/boot/vmlinuz-rpi2 ]; then
  config="$config
[pi2]
kernel=vmlinuz-rpi2
initramfs initramfs-rpi2
[pi3]
kernel=vmlinuz-rpi2
initramfs initramfs-rpi2
"
fi

if [ -f $MNT/boot/vmlinuz-rpi4 ]; then
  config="$config
[pi4]
enable_gic=1
arm_64bit=1
kernel=vmlinuz-rpi
initramfs initramfs-rpi
"
fi

  config="$config
[all]
include usercfg.txt
"

echo $config > $MNT/boot/config.txt

echo "dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait" > $MNT/boot/cmdline.txt

cat <<EOF > $MNT/etc/fstab
/dev/mmcblk0p1  /boot           vfat    defaults          0       2
/dev/mmcblk0p2  /               ext4    defaults,noatime  0       1
EOF
}
