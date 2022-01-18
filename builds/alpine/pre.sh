#!/bin/bash
set -e

jqi() {
  cat <<< "$(jq "$1" < "$2")" > "$2"
}

[ -z "$version" ] && {
  version=$(cat ../VERSION)
}


: ${arch:=x86_64}
qemu_arch=$arch
case $arch in
x86)
  qemu_arch=i386
  ;;
armhf)
  qemu_arch=arm
  ;;
armv7)
  qemu_arch=arm
  ;;
aarch64)
  qemu_machine_type=ast2500-evb
  ;;
esac
[ -z "$qemu_binary" ] && {
  qemu_binary=qemu-system-$qemu_arch
}

[ -z "$accel" ] && {
  accel=$($qemu_binary -accel ? | tail -1)
}

[ -z "$boot_wait" -a "$accel" != tcg ] && {
  boot_wait="15s"
}

: ${iso:=alpine-virt-${version}-${arch}.iso}

# generate local vars
echo '{}' > local.auto.pkrvars.json

for var in efi arch accel boot_wait dist flavor format size version qemu_binary qemu_machine_type iso; do
  [ -z "${!var}" ] || jqi ".$var=\"${!var}\"" local.auto.pkrvars.json
done

jq -s add 00-default.auto.pkrvars.json local.auto.pkrvars.json > local.final.json

# alpine-virt-3.13.0-x86_64.iso
jqv() {
  jq -r .$1 local.final.json
}
image=alpine-$(jqv flavor)-$(jqv version)-$(jqv arch)
[ -n "$(jqv efi)" ] && {
  image=$image-efi
}
image=$image.$(jqv format)
jqi ".image=\"${image}\"" local.final.json
cat local.final.json
