LO=$(losetup --partscan --show --find $1)
blkid ${LO}p2 | sed -nr 's/.*: UUID="([^"]+)".*/\1/p'
losetup -d $LO
# losetup -D
