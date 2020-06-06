conf-networking(){
  cat <<EOF > $MNT/etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF
}
