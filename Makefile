SHELL=/bin/bash

arch:=x86_64
version:=3.12.0
ver:=3.12
mirror:=https://mirrors.aliyun.com/alpine

minirootfs.tar.gz:=alpine-minirootfs-${version}-${arch}.tar.gz
minirootfs_url:=${mirror}/v${ver}/releases/${arch}/$(minirootfs.tar.gz)

#
cwd := $(notdir $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST))))))

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

sysfs: $(cwd)/scripts/sysfs-init.sh
	mkdir -p sysfs
	tar zxf $(minirootfs.tar.gz) -C sysfs
	$(cwd)/scripts/sysfs-init.sh

sysfs.apkvol.tar.gz: sysfs
	chroot sysfs/ lbu pkg sysfs.apkvol.tar.gz
	mv sysfs/sysfs.apkvol.tar.gz .

artifacts/sysfs.apkvol.tar.gz: sysfs.apkvol.tar.gz
	mkdir -p artifacts
	cp sysfs.apkvol.tar.gz artifacts
