default: join
	docker build .

join: 
	cat sources/disk/hda.qcow2-part* > sources/hda.qcow2

split:
	rm sources/disk/hda.qcow2-part*
	split -b 10M sources/hda.qcow2 sources/disk/hda.qcow2-part

launch-tianon-it: join
	echo "Useful for shrinking the hda image"
	echo "cd /tmp"
	echo "cp hda.qcow2 old.qcow2"
	echo "qemu-img convert -O qcow2 -p -c old.qcow2 hda.qcow2"
	docker run -it --rm \
		--name qemu-container-tianon \
		-v ./sources/hda.qcow2:/tmp/hda.qcow2 \
		-e QEMU_HDA=/tmp/hda.qcow2 \
		-e QEMU_HDA_SIZE=4G \
		-e QEMU_CPU=4 \
		-e QEMU_RAM=4096 \
		-v ./sources/alpine.iso:/tmp/alpine.iso:ro \
		-v ./sources/ext/entrypoint:/etc/init.d/entrypoint \
		-e QEMU_CDROM=/tmp/alpine.iso \
		-e QEMU_BOOT='order=c' \
		-e QEMU_PORTS='2375 2376' \
		--entrypoint "" \
		tianon/qemu \
		/bin/bash

launch-tianon: join
	touch ./sources/hda.qcow2
	docker run -it --rm \
		--name qemu-container-tianon \
		-v ./sources/hda.qcow2:/tmp/hda.qcow2 \
		-e QEMU_HDA=/tmp/hda.qcow2 \
		-e QEMU_HDA_SIZE=4G \
		-e QEMU_CPU=4 \
		-e QEMU_RAM=4096 \
		-v ./sources/alpine.iso:/tmp/alpine.iso:ro \
		-v ./sources/ext/entrypoint:/ext/entrypoint \
		-e QEMU_CDROM=/tmp/alpine.iso \
		-e QEMU_BOOT='order=c' \
		-e QEMU_PORTS='2375 2376' \
		tianon/qemu  start-qemu -virtfs local,path=/ext,mount_tag=host0,security_model=passthrough,id=host0

demo: join
	docker run -it -v ./demo-entrypoint:/ext/entrypoint eltorio/alpine-nested-qemu-docker:1.0.0

build: join
	docker build -t eltorio/alpine-nested-qemu-docker:1.0.0 .