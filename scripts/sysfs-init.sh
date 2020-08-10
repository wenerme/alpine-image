#!/bin/bash
set -ex

: ${arch:=x85_64}
: ${MNT:="$PWD/sysfs"}

cp /etc/apk/repositories sysfs/etc/apk/repositories
echo nameserver 114.114.114.114 > sysfs/etc/resolv.conf
# minimal packages
apk --root sysfs/ --arch $arch add alpine-base e2fsprogs openssh-server haveged haveged-openrc
#
echo root:root | chroot sysfs chpasswd

cat <<EOF > sysfs/etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF

# Service
# ==========
chmnt(){
  # chroot $MNT /bin/sh -c "$*"
  chroot $MNT $*
}
: ${TZ:="Asia/Shanghai"}

: ${SYSINIT_SERVICES:="devfs dmesg hwdrivers mdev"}
: ${SHUTDOWN_SERVICES:="killprocs mount-ro savecache"}
: ${BOOT_SERVICES:="bootmisc hostname modules swap hwclock sysctl syslog"}
: ${DEFAULT_SERVICES:="acpid local networking sshd ntpd haveged"}

#
for svc in $SYSINIT_SERVICES; do chmnt rc-update --quiet add $svc sysinit; done
for svc in $SHUTDOWN_SERVICES; do chmnt rc-update --quiet add $svc shutdown; done
# rpi swclock
for svc in $BOOT_SERVICES; do chmnt ln -fs /etc/init.d/$svc /etc/runlevels/boot; done
for svc in $DEFAULT_SERVICES; do chmnt rc-update --quiet add $svc default; done

chmnt setup-timezone -z $TZ
chmnt setup-keymap us us
chmnt ln -fs /etc/init.d/loadkmap /etc/runlevels/boot

chmnt rc-update
