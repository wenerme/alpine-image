## Reference
* https://mologie.github.io/blog/programming/2017/12/25/cross-compiling-cpp-with-cmake-llvm.html

## busybox-1.27.2-r7.trigger: line 20: /bin/bbsuid: Permission denied

Docker on macOS prevents writing suid binaries to volumes, resulting in:

   .../busybox-1.27.2-r7.trigger: line 20: /bin/bbsuid: Permission denied

The warning may be safely ignored, because we won't ever boot the sysroot.

## rc-update: failed to add service `loadkmap' to runlevel `boot': No such file or directory
* chroot 添加 boot runlevel 有问题
* 使用 ln - `ln -s /etc/init.d/$svc /etc/runlevels/boot`
