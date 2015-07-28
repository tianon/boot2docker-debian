FROM dockercore/boot2docker:docker

RUN { \
		echo 'VARIANT="VMware"'; \
		echo 'VARIANT_ID=vmware'; \
	} >> /etc/os-release
RUN echo ' (vmware)' >> /tmp/iso/version

RUN apt-get update && apt-get install -y --no-install-recommends \
		$(dpkg-query --show --showformat='${Package}\n' | awk '/^linux-image-[0-9]/ { gsub(/-image-/, "-headers-"); print }') \
		\
		open-vm-tools \
		open-vm-tools-dkms \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /mnt/hgfs && chown -R docker:docker /mnt/hgfs
RUN echo '.host:/ /mnt/hgfs vmhgfs nofail,uid=docker,gid=docker,noatime,nodiratime 0 0' >> /etc/fstab
