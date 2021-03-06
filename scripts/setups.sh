setup-rootfs(){
  wget -qcN ${rootfs_url}
  tar zxf $(basename ${rootfs_url}) -C $MNT
}
chmnt(){
  # chroot $MNT /bin/sh -c "$*"
  chroot $MNT $*
}

setup-chroot(){
  cp /etc/apk/repositories /alpine/etc/apk/repositories
  cp /etc/resolv.conf /alpine/etc/resolv.conf
  [ -d /etc/apk/cache ] && mkdir -p $MNT/etc/apk/cache && mount --bind /etc/apk/cache $MNT/etc/apk/cache 

  # none x86 need simulator
  apk update
  if case $ARCH in x86*) false;; *) true;; esac; then
    apk add -q qemu-$QEMU_ARCH
    cp /usr/bin/qemu-$QEMU_ARCH $MNT/usr/bin/qemu-$QEMU_ARCH
  fi

  chmnt uname -a || {
    file $MNT/bin/busybox $MNT/bin/sh
    lddtree $MNT/bin/busybox

    apk add -q strace
    # debug arm
    if case $ARCH in arm*) true;; aarch*) true;; *) false;; esac; then
      apk add -q qemu-$QEMU_ARCH
      cp /usr/bin/qemu-$QEMU_ARCH $MNT/usr/bin/qemu-$QEMU_ARCH
      # try sim
      strace chroot $MNT /usr/bin/qemu-$QEMU_ARCH /bin/busybox uname -a
    fi
    strace chroot $MNT /bin/busybox uname -a
    eerror chroot failed
  }
  chmnt apk update
  chmnt apk add -q alpine-base
}

setup-kernel(){
  chmnt apk add -q linux-$FLAVOR
}

setup-boot(){
  chmnt apk add -q syslinux e2fsprogs
  local kernel_opts="nomodeset quiet rootfstype=ext4"
  local modules="sd-mod,usb-storage,ext4"
  local root=$(blkid $ROOT_DEV | sed -nr 's/.*: (UUID="[^"]+").*/\1/p' | tr -d '"')
  local boot=$(blkid $BOOT_DEV | sed -nr 's/.*: (UUID="[^"]+").*/\1/p' | tr -d '"')

  cat <<EOF > $MNT/etc/update-extlinux.conf
overwrite=1
vesa_menu=0
default_kernel_opts="$kernel_opts"
modules=$modules
root=$root
verbose=0
hidden=1
timeout=3
default=$FLAVOR
serial_port=
serial_baud=115200
xen_opts=dom0_mem=256M
password=''
EOF

  extlinux --install $MNT/boot
  chmnt update-extlinux -v
  # extlinux --update $MNT/boot

  cat <<EOF | tee $MNT/etc/fstab
$root         /             ext4    rw,relatime,data=ordered  0 1
$boot         /boot         ext4    rw,relatime,data=ordered  0 1
/dev/cdrom    /media/cdrom  iso9660 noauto,ro                 0 0
/dev/usbdisk  /media/usb    vfat    noauto                    0 0
EOF

  #
  cat /usr/share/syslinux/mbr.bin > $LOOP_DEV

  # umount-root
  # cat /usr/share/syslinux/mbr.bin > $LOOP_DEV
  # mount-root
}

: ${SYSINIT_SERVICES:="devfs dmesg hwdrivers mdev"}
: ${BOOT_SERVICES:="bootmisc hostname modules swap hwclock sysctl syslog"}
: ${DEFAULT_SERVICES:="acpid local networking sshd ntpd haveged"}

setup-service(){

cat <<SH | chmnt /bin/sh
  [ ! -d /run/openrc ] && openrc sysinit
  apk add -q openssh haveged

  echo ${SYSINIT_SERVICES} | tr ' ' '\n' | xargs -n1 -I {} rc-update --quiet add {} sysinit
  echo ${BOOT_SERVICES} | tr ' ' '\n' | xargs -n1 -I {} rc-update --quiet add {} boot
  echo ${DEFAULT_SERVICES} | tr ' ' '\n' | xargs -n1 -I {} rc-update --quiet add {} default
  echo killprocs mount-ro savecache | tr ' ' '\n' | xargs -n1 -I {} rc-update --quiet add {} shutdown

  setup-timezone -z $TZ
  setup-keymap us us
SH
  chmnt rc-update
}

setup-conf(){
  conf-networking
}

setup-packages(){
  local packages=${PACKAGES:-"nano htop curl wget bash bash-completion"}
  chmnt apk add $packages
}

clean(){
  clean-chroot
}
clean-chroot(){
  rm -rf $MNT/var/cache/apk/* $MNT/usr/bin/qemu-* $MNT/etc/resolv.conf || true
}
