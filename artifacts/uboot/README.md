

```bash
# qemu-x86_64
qemu-system-x86_64 -nographic -bios artifacts/uboot/qemu-x86_64/u-boot.rom -hda alpine.img
# qemu-arm64
# -curses
qemu-system-aarch64 -nographic -machine virt -cpu cortex-a57 -bios artifacts/uboot/qemu-arm64/u-boot.bin
```
