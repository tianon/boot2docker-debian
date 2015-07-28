FROM dockercore/boot2docker:docker

RUN { \
		echo 'VARIANT="Parallels"'; \
		echo 'VARIANT_ID=parallels'; \
	} >> /etc/os-release
RUN echo ' (parallels)' >> /tmp/iso/version

RUN apt-get update && apt-get install -y --no-install-recommends \
		$(dpkg-query --show --showformat='${Package}\n' | awk '/^linux-image-[0-9]/ { gsub(/-image-/, "-headers-"); print }') \
		\
		make \
	&& rm -rf /var/lib/apt/lists/*

RUN rm /usr/local/bin/ar # we need "real" ar (not busybox ar)

ENV PRL_MAJOR 11
ENV PRL_VERSION 11.0.0
ENV PRL_BUILD 30916

RUN mkdir -p /tmp/prl_tools \
	&& wget -O- http://download.parallels.com/desktop/v${PRL_MAJOR}/${PRL_VERSION}-rtm/ParallelsTools-${PRL_VERSION}-${PRL_BUILD}-boot2docker.tar.gz \
		| tar -xzC /tmp/prl_tools --strip-components 1

RUN cd /tmp/prl_tools \
	&& ln -vL tools/usr/bin/* /usr/bin/ \
	&& ln -vL tools/usr/local/etc/init.d/prltoolsd /etc/init.d

RUN set -xe \
	&& for headers in /usr/src/linux-headers-*-$(dpkg --print-architecture); do \
		export KVER=${headers#/usr/src/linux-headers-}; \
		make -C /tmp/prl_tools/kmods -f Makefile.kmods SRC=/usr/src/linux-headers-$KVER PRL_FREEZE_SKIP=1 installme; \
		mkdir -p /lib/modules/$KVER/extra; \
		find /tmp/prl_tools/kmods -name '*.ko' -exec ln -vL '{}' /lib/modules/$KVER/extra/ ';'; \
		depmod -a $KVER; \
	done

# binaries installed directly to /usr/bin/ because the init scripts looks for them there specifically
RUN update-rc.d prltoolsd defaults
