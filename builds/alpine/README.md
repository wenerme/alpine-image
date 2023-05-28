# Build Base AlpineLinux Image

```bash
# Build dist/alpine-lts-3.13.5-x86_64.raw
flavor=lts format=raw make        # 用于直接 dd 到磁盘
efi=1 flavor=lts format=raw make  # 用于 阿里云
flavor=virt format=qcow2 make     # 用于云平台, 本地虚拟机
```

| var               | default                           |
| ----------------- | --------------------------------- |
| accel             | audo detect                       |
| arch              | x86_64                            |
| boot_wait         | 30s                               |
| dist              | images                            |
| efi               | `1` - build a uefi image          |
| flavor            | virt                              |
| format            | qcow2                             |
| iso               | alpine-$flavor-$version-$arch.iso |
| qemu_binary       | qemu-system-$arch                 |
| qemu_machine_type | pc                                |
| qemu_net_device   | virtio-net                        |
| size              | 40G                               |
| version           | builds/VERSION                    |
