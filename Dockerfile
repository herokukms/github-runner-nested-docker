FROM tianon/qemu
ENV QEMU_HDA_SIZE=4G
ENV QEMU_HDA=/tmp/hda.qcow2
ENV QEMU_HDA_SIZE=4G
ENV QEMU_CPU=4
ENV QEMU_RAM=4096
ENV QEMU_CDROM=/tmp/alpine.iso
ENV QEMU_BOOT='order=c'
ENV QEMU_PORTS='2375 2376'
COPY sources/alpine.iso /tmp/alpine.iso
COPY sources/hda.qcow2 /tmp/hda.qcow2
RUN apt update -y && apt install -y  telnet
CMD ["/usr/local/bin/start-qemu", "-virtfs", "local,path=/ext,mount_tag=host0,security_model=passthrough,id=host0","-serial", "telnet:127.0.0.1:23,server,nowait"]