all: boot2docker-base.iso boot2docker-generic.iso boot2docker-hyperv.iso boot2docker-parallels.iso boot2docker-virtualbox.iso boot2docker-vmware.iso
	@echo; echo
	@ls -lh $^
.PHONY: all

clean:
	rm -v boot2docker-*.iso
.PHONY: clean

boot2docker-base.iso: docker-build.base
	docker run --rm dockercore/boot2docker:base sh -c 'build-iso.sh >&2 && cat /tmp/docker.iso' > $@
	@ls -lh $@

docker-build.base: Dockerfile.base scripts/generate-ssh-host-keys.sh inits/ssh-keygen.init scripts/initramfs-live-hook.sh scripts/initramfs-live-script.sh excludes scripts/audit-rootfs.sh scripts/build-rootfs.sh scripts/build-iso.sh
	docker build -t dockercore/boot2docker:base -f $< .
	@echo
	@docker images dockercore/boot2docker | awk 'NR == 1 || $$2 == "base" { print }'
	@echo
explore-base: docker-build.base
	docker run -it --rm dockercore/boot2docker:base
audit-base: docker-build.base
	docker run -it --rm dockercore/boot2docker:base sh -c 'audit-rootfs.sh 2>&1 | sort | less'
.PHONY: docker-build.base explore-base audit-base

boot2docker-generic.iso: docker-build.generic
	docker run --rm dockercore/boot2docker:generic sh -c 'build-iso.sh >&2 && cat /tmp/docker.iso' > $@
	@ls -lh $@

docker-build.generic: Dockerfile.generic scripts/autoformat.sh inits/autoformat.init docker-build.base
	docker build -t dockercore/boot2docker:generic -f $< .
	@echo
	@docker images dockercore/boot2docker | awk 'NR == 1 || $$2 == "generic" { print }'
	@echo
explore-generic: docker-build.generic
	docker run -it --rm dockercore/boot2docker:generic
audit-generic: docker-build.generic
	docker run -it --rm dockercore/boot2docker:generic sh -c 'audit-rootfs.sh 2>&1 | sort | less'
.PHONY: docker-build.generic explore-generic audit-generic

boot2docker-hyperv.iso: docker-build.hyperv
	docker run --rm dockercore/boot2docker:hyperv sh -c 'build-iso.sh >&2 && cat /tmp/docker.iso' > $@
	@ls -lh $@

docker-build.hyperv: Dockerfile.hyperv docker-build.generic
	docker build -t dockercore/boot2docker:hyperv -f $< .
	@echo
	@docker images dockercore/boot2docker | awk 'NR == 1 || $$2 == "hyperv" { print }'
	@echo
explore-hyperv: docker-build.hyperv
	docker run -it --rm dockercore/boot2docker:hyperv
audit-hyperv: docker-build.hyperv
	docker run -it --rm dockercore/boot2docker:hyperv sh -c 'audit-rootfs.sh 2>&1 | sort | less'
.PHONY: docker-build.hyperv explore-hyperv audit-hyperv

boot2docker-parallels.iso: docker-build.parallels
	docker run --rm dockercore/boot2docker:parallels sh -c 'build-iso.sh >&2 && cat /tmp/docker.iso' > $@
	@ls -lh $@

docker-build.parallels: Dockerfile.parallels docker-build.generic
	docker build -t dockercore/boot2docker:parallels -f $< .
	@echo
	@docker images dockercore/boot2docker | awk 'NR == 1 || $$2 == "parallels" { print }'
	@echo
explore-parallels: docker-build.parallels
	docker run -it --rm dockercore/boot2docker:parallels
audit-parallels: docker-build.parallels
	docker run -it --rm dockercore/boot2docker:parallels sh -c 'audit-rootfs.sh 2>&1 | sort | less'
.PHONY: docker-build.parallels explore-parallels audit-parallels

boot2docker-virtualbox.iso: docker-build.virtualbox
	docker run --rm dockercore/boot2docker:virtualbox sh -c 'build-iso.sh >&2 && cat /tmp/docker.iso' > $@
	@ls -lh $@

docker-build.virtualbox: Dockerfile.virtualbox docker-build.generic
	docker build -t dockercore/boot2docker:virtualbox -f $< .
	@echo
	@docker images dockercore/boot2docker | awk 'NR == 1 || $$2 == "virtualbox" { print }'
	@echo
explore-virtualbox: docker-build.virtualbox
	docker run -it --rm dockercore/boot2docker:virtualbox
audit-virtualbox: docker-build.virtualbox
	docker run -it --rm dockercore/boot2docker:virtualbox sh -c 'audit-rootfs.sh 2>&1 | sort | less'
.PHONY: docker-build.virtualbox explore-virtualbox audit-virtualbox

boot2docker-vmware.iso: docker-build.vmware
	docker run --rm dockercore/boot2docker:vmware sh -c 'build-iso.sh >&2 && cat /tmp/docker.iso' > $@
	@ls -lh $@

docker-build.vmware: Dockerfile.vmware docker-build.generic
	docker build -t dockercore/boot2docker:vmware -f $< .
	@echo
	@docker images dockercore/boot2docker | awk 'NR == 1 || $$2 == "vmware" { print }'
	@echo
explore-vmware: docker-build.vmware
	docker run -it --rm dockercore/boot2docker:vmware
audit-vmware: docker-build.vmware
	docker run -it --rm dockercore/boot2docker:vmware sh -c 'audit-rootfs.sh 2>&1 | sort | less'
.PHONY: docker-build.vmware explore-vmware audit-vmware
