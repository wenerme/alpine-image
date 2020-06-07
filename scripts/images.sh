
: ${IMAGE_SIZE:=2G}
image-create(){
  local size=$IMAGE_SIZE
  rm -f "$TARGET_IMG"
  truncate -s $size "$TARGET_IMG"
  everbose Crete image $TARGET_IMG $size
}

image-partation(){
  local boot_size=${BOOT_SIZE:-100MB}
  # 83 - Linux
  # c - win fat32 -rpi
  local boot_part_type=${BOOT_PART_TYPE:-83}
  # -H 255 -S 63 
  fdisk ${IMAGE_FDISK_OPTS} "$TARGET_IMG" <<-EOF
o
n
p
1

+${boot_size}
t
${boot_part_type}
n
p
2


a
1
w
EOF
}

# preset
: ${LOOP_DEV:="/dev/loop0"}
: ${BOOT_DEV:="/dev/loop0p1"}
: ${ROOT_DEV:="/dev/loop0p2"}
mount-loop(){
  LOOP_DEV=$(losetup --partscan --show --find "${TARGET_IMG}")
  BOOT_DEV="$LOOP_DEV"p1
  ROOT_DEV="$LOOP_DEV"p2
}

image-mkfs(){
  # mkfs.fat -F32 - rpi
  # -n Alpine-${ARCH}-${FLAVOR}-${ALPINE_VERSION} 
  ${IMAGE_MKFS_BOOT:-mkfs.ext4} "$BOOT_DEV"
  ${IMAGE_MKFS_ROOT:-mkfs.ext4} "$ROOT_DEV"
}

mount-root(){
  mkdir -p $MNT
  mount --make-private "$ROOT_DEV" $MNT
  mkdir -p $MNT/boot
  mount --make-private "$BOOT_DEV" $MNT/boot
}

umount-root(){
  umount -lf $MNT
}

umount-loop(){
  losetup -d "$LOOP_DEV" || true
}

mount-all(){
  mount-loop
  mount-root
}
umount-all(){
  umount-root
  umount-loop
}


image-shrink(){
  #
  umount-root
  # shrink image
  ROOT_PART_START=$(parted -ms "$TARGET_IMG" unit B print | tail -n 1 | cut -d ':' -f 2 | tr -d 'B')
  ROOT_BLOCK_SIZE=$(tune2fs -l "$ROOT_DEV" | grep '^Block size:' | tr -d ' ' | cut -d ':' -f 2)
  ROOT_MIN_SIZE=$(resize2fs -P "$ROOT_DEV" | cut -d ':' -f 2 | tr -d ' ')

  # shrink fs
  e2fsck -f -p "$ROOT_DEV"
  resize2fs -p "$ROOT_DEV" $ROOT_MIN_SIZE

  # shrink partition
  PART_END=$(($ROOT_PART_START + ($ROOT_MIN_SIZE * $ROOT_BLOCK_SIZE)))
  parted -s ---pretend-input-tty "$TARGET_IMG" unit B resizepart 2 $PART_END yes
  losetup -d "$LOOP_DEV"

  # truncate free space
  FREE_START=$(parted -ms "$TARGET_IMG" unit B print free | tail -1 | cut -d ':' -f 2 | tr -d 'B')
  truncate -s $FREE_START "$TARGET_IMG"
}

image-gz(){
  everbose Compressing image to dist
  mkdir -p dist
  pigz -9 -c "$TARGET_IMG" > "dist/alpine-${ARCH}-${FLAVOR}-${ALPINE_VERSION}.img.gz"
}
