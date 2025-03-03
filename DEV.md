# Generate checksum

```bash
cat {v3.16,v3.15,v3.14,v3.13,v3.12}/releases/{x86_64,aarch64,x86,armhf,armv7}/alpine-*.sha256 | grep -v -e _rc -e xen -e miniroot -e netboot > checksums.txt

cat checksums.txt | awk ' { t = $1; $1 = $2; $2 = t; print; } ' | sort > checksums-sort.txt

echo '{ "checksums":{' > checksums.json
cat checksums-sort.txt | awk '{printf "\"%s\":\"%s\",\n",$1,$2}' >> checksums.json
echo '"":""' >> checksums.json
echo '}}' >> checksums.json

cat checksums.json | jq -r > checksums.auto.pkrvars.json

# scp admin@host:/alpine/mirror/checksums.auto.pkrvars.json builds/alpine
```

# Get ver from os-release

```bash
egrep -o 'VERSION_ID=[0-9]+[.]+[0-9]+' /etc/os-release | egrep -o '[0-9]+[.]+[0-9]+'
```

# qemu-system-aarch64: -device virtio-net,netdev=user.0: No 'PCI' bus found for device 'virtio-net-pci'

- 网络设备使用 usb-net
- QEMU 5.1.0+, 5.0.1+

```bash
qemu-system-aarch64 \
  -m 1024 -M raspi3 \
  -kernel kernel8.img -dtb bcm2710-rpi-3-b-plus.dtb \
  -sd armhf.img \
  -append "console=ttyAMA0 root=/dev/mmcblk0p2 rw rootwait rootfstype=ext4" \
  -nographic \
  -device usb-net,netdev=net0 -netdev user,id=net0,hostfwd=tcp::5555-:22
```

# Sync spare image to remote

```bash
# -S support spare
rsync -aPS --no-owner dist/alpine-lts-3.13.2-x86_64.raw admin@192.168.1.2:~
```

# dd image to disk

```bash
# enable spare
sudo dd if=images/alpine-lts-3.13.2-x86_64.raw of=/dev/sda conv=sparse status=progress bs=128MB
```

# qemu boot from disk

- qemu default mac 52:54:00:12:34:56

```bash
# -uuid $(dmidecode -s system-uuid) use same uuid as host
# -device virtio-net,netdev=n1,mac=52:54:00:12:34:60 - use different mac
qemu-system-x86_64 -accel kvm -m 1G -vnc :1 /dev/sda -curses -netdev bridge,br=br0,id=n1 -device virtio-net,netdev=n1
```

## test image

```bash
qemu-system-x86_64 -accel hvf -m 1G -drive file=dist/alpine-virt-3.14.0-x86_64.qcow2 -net nic -net user,hostfwd=tcp::2222-:22
# ssh login root:root
ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no root@127.0.0.1 -p 2222
```
