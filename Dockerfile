FROM debian:jessie

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		aufs-tools \
		bash-completion \
		btrfs-tools \
		busybox \
		ca-certificates \
		dbus \
		ifupdown \
		iptables \
		isc-dhcp-client \
		linux-image-3.16.0-4-amd64 \
		openssh-server \
		rsync \
		sudo \
		sysvinit \
		\
		sysvinit-core \
		\
		squashfs-tools \
		xorriso \
		xz-utils \
		\
		isolinux \
		syslinux-common \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /etc/ssh/ssh_host_* \
	&& mkdir -p /tmp/iso/isolinux \
	&& ln -L /usr/lib/ISOLINUX/isolinux.bin /usr/lib/syslinux/modules/bios/* /tmp/iso/isolinux/ \
	&& ln -L /usr/lib/ISOLINUX/isohdpfx.bin /tmp/ \
	&& apt-get purge -y --auto-remove \
		isolinux \
		syslinux-common

#		apparmor \
# see https://wiki.debian.org/AppArmor/HowTo and isolinux.cfg

#		curl \
#		wget \

# BUSYBOX ALL UP IN HERE
RUN set -e \
	&& busybox="$(which busybox)" \
	&& for m in $("$busybox" --list); do \
		if ! command -v "$m" > /dev/null; then \
			ln -vL "$busybox" /usr/local/bin/"$m"; \
		fi; \
	done

# if /etc/machine-id is empty, systemd will generate a suitable ID on boot
RUN echo -n > /etc/machine-id

# setup networking (hack hack hack)
# TODO find a better way to do this natively via some eth@.service magic (like the getty magic) and remove ifupdown completely
RUN for iface in eth0 eth1 eth2 eth3; do \
		{ \
			echo "auto $iface"; \
			echo "allow-hotplug $iface"; \
			echo "iface $iface inet dhcp"; \
		} > /etc/network/interfaces.d/$iface; \
	done

# COLOR PROMPT BABY
RUN sed -ri 's/^#(force_color_prompt=)/\1/' /etc/skel/.bashrc \
	&& cp /etc/skel/.bashrc /root/

# setup our non-root user, set passwords for both users, and setup sudo
RUN useradd --create-home --shell /bin/bash docker \
	&& { \
		echo 'root:docker'; \
		echo 'docker:docker'; \
	} | chpasswd \
	&& echo 'docker ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/docker

# autologin for all tty
# see also: grep ^ExecStart /lib/systemd/system/*getty@.service
RUN mkdir -p /etc/systemd/system/getty@.service.d && { \
		echo '[Service]'; \
		echo 'ExecStart='; \
		echo 'ExecStart=-/sbin/agetty --autologin docker --noclear %I $TERM'; \
	} > /etc/systemd/system/getty@.service.d/autologin.conf
RUN mkdir -p /etc/systemd/system/serial-getty@.service.d && { \
		echo '[Service]'; \
		echo 'ExecStart='; \
		echo 'ExecStart=-/sbin/agetty --autologin docker --keep-baud 115200,38400,9600 %I $TERM'; \
	} > /etc/systemd/system/serial-getty@.service.d/autologin.conf

# setup inittab for autologin too (in case of sysvinit)
RUN set -e && { \
	echo 'id:2:initdefault:'; \
	echo 'si::sysinit:/etc/init.d/rcS'; \
	for i in 0 1 2 3 4 5 6; do \
		echo "l$i:$i:wait:/etc/init.d/rc $i"; \
	done; \
	for tty in 1 2 3 4 5 6; do \
		[ $tty = 1 ] && rl=2345 || rl=23; \
		echo "$tty:$rl:respawn:/sbin/getty --autologin docker --noclear 38400 tty$tty"; \
	done; \
	for ttyS in 0 1; do \
		echo "T$ttyS:23:respawn:/sbin/getty --autologin docker -L ttyS$ttyS 9600 vt100"; \
	done; \
} > /etc/inittab

# DOCKER DOCKER DOCKER
ENV DOCKER_VERSION 1.5.0
COPY docker-${DOCKER_VERSION} /usr/local/bin/docker

COPY docker.service /etc/systemd/system/
RUN systemctl enable docker.service

COPY docker.sysvinit /etc/init.d/docker
RUN update-rc.d docker defaults

# PURE VANITY
RUN { echo; echo 'Docker (\\s \\m \\r) [\\l]'; echo; } > /etc/issue \
	&& { echo; docker -v; echo; } > /etc/motd

COPY initramfs-live-hook.sh /usr/share/initramfs-tools/hooks/live
COPY initramfs-live-script.sh /usr/share/initramfs-tools/scripts/live

COPY excludes /tmp/
COPY build-iso.sh /usr/local/bin/

RUN build-iso.sh # creates /tmp/docker.iso
