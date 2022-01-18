

```bash
rm -f {vmlinuz,modloop,initramfs}-virt
wget https://mirrors.aliyun.com/alpine/v3.12/releases/x86_64/netboot/{vmlinuz,modloop,initramfs}-virt
# use kernel and initrd
# qfw load
# zboot 0000000001000000 5632a0 0000000004000000 453acb 
qemu-system-x86_64 -nographic \
  -bios artifacts/uboot/qemu-x86_64/u-boot.rom \
  -kernel vmlinuz-virt \
  -initrd initramfs-virt

# qemu-x86_64
qemu-system-x86_64 -nographic -bios artifacts/uboot/qemu-x86_64/u-boot.rom -hda alpine.img
# qemu-arm64
# -curses
wget https://mirrors.aliyun.com/alpine/v3.12/releases/aarch64/netboot/{vmlinuz,modloop,initramfs}-lts
# qemu-system-aarch64 -nographic -machine virt -cpu cortex-a57 -bios u-boot.bin \
#   -kernel vmlinuz-lts \
#   -initrd initramfs-lts

qemu-system-aarch64 -nographic -machine virt -cpu cortex-a57 -bios artifacts/uboot/qemu-arm64/u-boot.bin
```

qemu-system-x86_64 -vnc :10 -serial stdio -m 1024 -M pc \
  -bios u-boot.rom \
  -kernel vmlinuz-virt \
  -initrd initramfs-virt
