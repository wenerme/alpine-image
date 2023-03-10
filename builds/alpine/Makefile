SHELL=/bin/bash

build: local.final.json
	PACKER_LOG=$(verbose) \
	packer build $(PACKER_FLAGS) .
	mkdir -p dist
	mv images/packer-alpine dist/$$(jq -r .image local.final.json)

.PHONEY: always
always:

local.final.json: always
	./pre.sh
	rm -rf $$(jq -r .dist local.final.json)
	[ -e dist/$$(jq -r .image local.final.json) ] && false || true

boot:
	qemu-system-x86_64 $$QEMU_FLAGS -m 4G -smp 2 -net nic -nic user,hostfwd=tcp::2222-:22 -drive if=virtio,file=dist/$$(jq -r .image local.final.json)

.PHONEY: clean
clean:
	rm -rf images packer_cache

fmt:
	packer fmt .

dd:
	[ -n "$(DISK)" ]
	diskutil umountdisk $(DISK)
	sudo dd if=dist/$(shell jq -r '.image' local.final.json) of=/dev/r$(DISK) conv=sparse status=progress bs=128MB
	diskutil eject $(DISK)
