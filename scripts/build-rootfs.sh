#!/bin/bash
set -e

# /etc/hostname, /etc/hosts, and /etc/resolv.conf are all bind-mounts in Docker, so we have to set them up here instead of in the Dockerfile or the changes won't stick
grep -q ' /etc/hostname ' /proc/mounts # sanity check
echo 'docker' > /etc/hostname

{
	echo '127.0.0.1   localhost docker'
	echo '::1         localhost ip6-localhost ip6-loopback'
	echo 'fe00::0     ip6-localnet'
	echo 'ff00::0     ip6-mcastprefix'
	echo 'ff02::1     ip6-allnodes'
	echo 'ff02::2     ip6-allrouters'
} > /etc/hosts

{
	echo 'nameserver 8.8.8.8'
	echo 'nameserver 8.8.4.4'
} > /etc/resolv.conf

echo >&2 'Building the rootfs tarball ...'
tar --exclude-from /tmp/excludes -cJf /tmp/rootfs.tar.xz /
