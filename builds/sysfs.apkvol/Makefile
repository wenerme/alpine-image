SHELL=/bin/bash

arch?=x86_64
version?=3.13.2
ver:=$(basename $(version))
mirror?=https://mirrors.aliyun.com/alpine

minirootfs.tar.gz:=alpine-minirootfs-${version}-${arch}.tar.gz
minirootfs_url:=${mirror}/v${ver}/releases/${arch}/$(minirootfs.tar.gz)

# for relative scripts
cwd := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

love:
	@echo No target
	@exit 1

report:
	@echo Alpine $(arch) $(flavor) $(ver)/$(version)
	@echo Repo $(mirror)
	@echo CWD $(cwd)

$(minirootfs.tar.gz):
	curl -LOC- $(minirootfs_url)

rootfs: $(minirootfs.tar.gz)
	mkdir -p rootfs
	tar zxf $(minirootfs.tar.gz) -C rootfs
	#
	cp /etc/apk/repositories rootfs/etc/apk/
	apk --root rootfs add alpine-conf

rootfs.apkvol.tar.gz: rootfs
	chroot rootfs/ lbu pkg rootfs.apkvol.tar.gz
	mv rootfs/rootfs.apkvol.tar.gz .

sysfs: sysfs-init.sh $(minirootfs.tar.gz)
	mkdir -p sysfs
	tar zxf $(minirootfs.tar.gz) -C sysfs
	arch=$(arch) sh ./sysfs-init.sh
	echo Alpine $(arch) $(version) sysfs

sysfs.apkvol.tar.gz: sysfs
	chroot sysfs/ lbu pkg sysfs.apkvol.tar.gz
	mv sysfs/sysfs.apkvol.tar.gz .

# /etc/apk/arch = apk --print-arch
sysfs.%.apkvol.tar.gz:
	rm -rf sysfs sysfs.apkvol.tar.gz
	arch=$* $(MAKE) sysfs.apkvol.tar.gz
	cp sysfs.apkvol.tar.gz sysfs.$*.apkvol.tar.gz
	echo Alpine $(arch) $(version) sysfs.apkvol.tar.gz

clean:
	-rm -rf sysfs
distclean: clean
	-rm -rf sysfs*.apkvol.tar.gz
