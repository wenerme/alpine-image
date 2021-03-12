# Generate checksum

```bash
cat {v3.13,v3.12}/releases/{x86_64,aarch64,x86,armhf,armv7}/alpine-*.sha256 | grep -v -e _rc -e xen -e miniroot -e netboot > checksums.txt

cat checksums.txt | awk ' { t = $1; $1 = $2; $2 = t; print; } ' | sort > checksums-sort.txt

echo '{ "checksums":{' > checksums.json
cat checksums-sort.txt | awk '{printf "\"%s\":\"%s\",\n",$1,$2}' >> checksums.json
echo '"":""' >> checksums.json
echo '}}' >> checksums.json

cat checksums.json | jq -r > checksums.auto.pkrvars.json

# scp admin@host:/alpine/mirror/checksums.auto.pkrvars.json builds/alpine
```

## Get ver from os-release

```bash
egrep -o 'VERSION_ID=[0-9]+[.]+[0-9]+' /etc/os-release | egrep -o '[0-9]+[.]+[0-9]+'
```

# qemu-system-aarch64: -device virtio-net,netdev=user.0: No 'PCI' bus found for device 'virtio-net-pci'

* 网络设备使用 usb-net
* QEMU 5.1.0+, 5.0.1+

```bash
qemu-system-aarch64 \
  -m 1024 -M raspi3 \
  -kernel kernel8.img -dtb bcm2710-rpi-3-b-plus.dtb \
  -sd armhf.img \
  -append "console=ttyAMA0 root=/dev/mmcblk0p2 rw rootwait rootfstype=ext4" \
  -nographic \
  -device usb-net,netdev=net0 -netdev user,id=net0,hostfwd=tcp::5555-:22
```
