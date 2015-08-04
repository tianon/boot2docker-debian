FROM dockercore/boot2docker:docker

RUN { \
		echo 'VARIANT="Hyper-V"'; \
		echo 'VARIANT_ID=hyperv'; \
	} >> /etc/os-release
RUN echo ' (hyperv)' >> /tmp/iso/version

# we need "hyperv-daemons" which only exists in sid right now
RUN echo 'deb http://httpredir.debian.org/debian sid main' > /etc/apt/sources.list.d/sid.list

RUN apt-get update && apt-get install -y hyperv-daemons && rm -rf /var/lib/apt/lists/*
