#!/bin/bash
set -e

jqi() {
  cat <<< "$(jq "$1" < "$2")" > "$2"
}

sha256() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
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

if [ -z "$flavor" ]; then
  flavor=$(jq -r '.flavor' 00-default.auto.pkrvars.json)
fi
iso_flavor=standard
[ "$flavor" = "virt" ] && iso_flavor=virt
: ${iso:=alpine-${iso_flavor}-${version}-${arch}.iso}

# generate local vars
echo '{}' > local.auto.pkrvars.json

for var in efi arch accel boot_wait dist flavor format size version qemu_binary qemu_machine_type iso; do
  [ -z "${!var}" ] || jqi ".$var=\"${!var}\"" local.auto.pkrvars.json
done

checksum=$(jq -r --arg iso "$iso" '.checksums[$iso] // empty' checksums.auto.pkrvars.json)
[ -n "$checksum" ] || {
  echo "Missing checksum for $iso. Run: flavor=$flavor VER=$version make update-checksum" >&2
  exit 1
}

mkdir -p iso-cache
iso_file="iso-cache/$iso"
iso_tmp="$iso_file.tmp"
trap 'rm -f "$iso_tmp"' EXIT

got=""
[ -e "$iso_file" ] && got=$(sha256 "$iso_file")
[ "$got" = "$checksum" ] || {
  rm -f "$iso_file"
  ver=${version%.*}
  mirrors=(
    "https://mirrors.tuna.tsinghua.edu.cn/alpine"
    "https://mirrors.aliyun.com/alpine"
    "https://mirrors.sjtug.sjtu.edu.cn/alpine"
  )
  for mirror in "${mirrors[@]}"; do
    url="$mirror/v$ver/releases/$arch/$iso"
    echo "Downloading $url"
    curl -fL --retry 3 --retry-delay 2 -A "curl" -o "$iso_tmp" "$url" || continue
    got=$(sha256 "$iso_tmp")
    [ "$got" = "$checksum" ] || {
      echo "Checksum mismatch from $mirror: expected $checksum got $got" >&2
      rm -f "$iso_tmp"
      continue
    }
    mv "$iso_tmp" "$iso_file"
    break
  done
}

got=""
[ -e "$iso_file" ] && got=$(sha256 "$iso_file")
[ "$got" = "$checksum" ] || {
  echo "Failed to download $iso with checksum $checksum" >&2
  exit 1
}
iso_url="file://$PWD/$iso_file"
jqi ".iso_url=\"${iso_url}\"" local.auto.pkrvars.json

jq -s add 00-default.auto.pkrvars.json local.auto.pkrvars.json > local.final.json

# alpine-virt-3.13.0-x86_64.iso
jqv() {
  jq -r .$1 local.final.json
}
image=alpine-$(jqv flavor)-$(jqv version)-$(jqv arch)
[ -n "$(jqv efi)" ] && {
  image=$image-efi
}
image=$image-$(jqv size)

image=$image.$(jqv format)
jqi ".image=\"${image}\"" local.final.json
cat local.final.json
