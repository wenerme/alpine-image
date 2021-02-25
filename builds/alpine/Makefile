SHELL=/bin/bash

build:
	./pre.sh
	rm -rf $$(jq -r .dist local.final.json)
	[ -e dist/$$(jq -r .image local.final.json) ] && false || true
	PACKER_LOG=$(verbose) \
	packer build $(PACKER_FLAGS) .
	mkdir -p dist
	mv images/packer-alpine dist/$$(jq -r .image local.final.json)

boot:
	qemu-system-x86_64 $$QEMU_FLAGS -m 4G -smp 2 -net nic -nic user,hostfwd=tcp::2222-:22 -drive if=virtio,file=dist/$$(jq -r .image local.final.json)

.PHONEY: clean
clean:
	rm -rf images packer_cache
