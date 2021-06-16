# Build Base AlpineLinux Image

```bash
# Build dist/alpine-lts-3.13.5-x86_64.raw
flavor=lts format=raw make
```

| var               | default                           |
| ----------------- | --------------------------------- |
| accel             | audo detect                       |
| arch              | x86_64                            |
| boot_wait         | 30s                               |
| dist              | images                            |
| flavor            | virt                              |
| format            | qcow2                             |
| iso               | alpine-$flavor-$version-$arch.iso |
| qemu_binary       | qemu-system-$arch                 |
| qemu_machine_type | pc                                |
| qemu_net_device   | virtio-net                        |
| size              | 40G                               |
| version           | builds/VERSION                    |
| efi               |                                   |

> set efi to `1` to build a uefi image
