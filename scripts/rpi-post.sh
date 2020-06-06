
BOOT_SERVICES=$(echo $BOOT_SERVICES | sed 's/hwclock//g')
BOOT_SERVICES="${BOOT_SERVICES} swclock"

setup-kernel(){
  chmnt apk add linux-rpi
  # https://pkgs.alpinelinux.org/packages?name=linux-rpi*&branch=v3.12
  [ "aarch64" = "$ARCH" ] && chmnt apk add linux-rpi4
  [ "armv7" = "$ARCH" ] && chmnt apk add linux-rpi2 linux-rpi4
  [ "armhf" = "$ARCH" ] && chmnt apk add linux-rpi2
}
