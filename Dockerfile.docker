FROM dockercore/boot2docker:base

# DOCKER DOCKER DOCKER

# https://github.com/docker/docker/blob/master/project/PACKAGERS.md#system-dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
		aufs-tools \
		btrfs-tools \
		iptables \
		\
		nfs-common \
		parted \
		util-linux \
	&& rm -rf /var/lib/apt/lists/*

#		git \
#		lxc \

# this is how one would install a .deb from the context instead of via apt
#COPY docker-engine*.deb /tmp/
#RUN dpkg --unpack /tmp/docker-engine*.deb \
#	&& apt-get update \
#	&& apt-get install -y --no-install-recommends -f \
#	&& rm -rf /var/lib/apt/lists/*

RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
RUN echo 'deb http://apt.dockerproject.org/repo debian-jessie main testing experimental' > /etc/apt/sources.list.d/docker.list
RUN { \
		echo 'Package: *'; \
		echo 'Pin: release o=Docker, c=main'; \
		echo 'Pin-Priority: 900'; \
		echo; \
		echo 'Package: *'; \
		echo 'Pin: release o=Docker, c=testing'; \
		echo 'Pin-Priority: 800'; \
		echo; \
		echo 'Package: *'; \
		echo 'Pin: release o=Docker, c=experimental'; \
		echo 'Pin-Priority: 700'; \
	} > /etc/apt/preferences.d/docker

ENV DOCKER_VERSION 1.10.1-0~jessie
#ENV DOCKER_VERSION 1.11.0~dev*
RUN apt-get update && apt-get install -y --no-install-recommends \
		docker-engine=$DOCKER_VERSION \
	&& rm -rf /var/lib/apt/lists/*

# PURE VANITY
RUN { echo; docker -v; echo; } > /etc/motd
RUN docker -v > /tmp/iso/version
RUN { \
		echo 'PRETTY_NAME="boot2docker, '"$(docker -v)"'"'; \
		echo 'NAME="boot2docker"'; \
		echo 'VERSION_ID="'"$(docker -v | sed -r 's/.* version ([^ ,]+).*/\1/')"'"'; \
		echo 'VERSION="'"$(dpkg-query --show --showformat='${Version}' docker-engine)"'"'; \
		echo 'ID=docker'; \
		echo 'ID_LIKE="debian boot2docker"'; \
		echo 'HOME_URL="https://dockerproject.org"'; \
	} > /etc/os-release

COPY scripts/autoformat.sh /usr/local/sbin/
COPY inits/autoformat /etc/init.d/
RUN update-rc.d autoformat defaults

COPY inits/boot2docker-hooks-* /etc/init.d/
RUN set -ex \
	&& for t in before after; do \
		update-rc.d boot2docker-hooks-$t-docker defaults; \
		mkdir -p /etc/boot2docker/hooks/$t-docker.d; \
	done \
	&& chown -R docker:docker /etc/boot2docker

#RUN build-iso.sh # creates /tmp/docker.iso
