default: join
	docker build .

join: 
	cat sources/disk/hda.qcow2-part* > sources/hda.qcow2

split:
	rm -f sources/disk/hda.qcow2-part*
	split -b 10M sources/hda.qcow2 sources/disk/hda.qcow2-part

joinbase: 
	cat sources/base/hda.qcow2-part* > sources/hda.qcow2

splitbase:
	rm sources/base/hda.qcow2-part*
	split -b 10M sources/hda.qcow2 sources/base/hda.qcow2-part

pullrunner: joinbase
	touch ./sources/hda.qcow2
	BUILD_SHA=`docker build -q .` ;\
	echo "$(BUILD_SHA)" ;\
	docker run -it $(BUILD_SHA) --rm \
		--name qemu-container-tianon \
		-v ./sources/hda.qcow2:/tmp/hda.qcow2 \
		-e QEMU_HDA=/tmp/hda.qcow2 \
		-e QEMU_HDA_SIZE=4G \
		-e QEMU_CPU=4 \
		-e QEMU_RAM=4096 \
		-v ./sources/alpine.iso:/tmp/alpine.iso:ro \
		-v ./sources/ext/load-image:/ext/entrypoint \
		-e QEMU_CDROM=/tmp/alpine.iso \
		-e QEMU_BOOT='order=c' \
		-e QEMU_PORTS='2375 2376' \
		tianon/qemu  start-qemu -virtfs local,path=/ext,mount_tag=host0,security_model=passthrough,id=host0 -serial telnet:127.0.0.1:23,server,nowait

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
		tianon/qemu  start-qemu -virtfs local,path=/ext,mount_tag=host0,security_model=passthrough,id=host0 -serial telnet:127.0.0.1:23,server,nowait

demo: join
	./test.sh

build: join
	docker build -t herokukms/github-runner-nested:1.0.0 .

test: build
	docker run -it -v ./demo-entrypoint:/ext/entrypoint:ro herokukms/github-runner-nested:1.0.0 /bin/bash
