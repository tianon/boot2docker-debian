#!/bin/bash
set -e

cd "$(dirname "$BASH_SOURCE")"

variants=( Dockerfile.* )
variants=( "${variants[@]#Dockerfile.}" )
image='dockercore/boot2docker'

echo -n 'all:'
for variant in "${variants[@]}"; do
	[ "$variant" = 'base' -o "$variant" = 'docker' ] && continue # exclude non-release ISOs from "all"
	echo -n " boot2docker-$variant.iso"
done
echo
cat <<'EOB'
	@echo; echo
	@ls -lh $^
.PHONY: all
EOB

for variant in "${variants[@]}"; do
	from="$(awk 'toupper($1) == "FROM" { print $2; exit }' "Dockerfile.$variant")"

	deps=(
		"Dockerfile.$variant"
		$(awk 'toupper($1) == "COPY" { for (i = 2; i < NF; i++) { print $i } }' "Dockerfile.$variant")
	)
	if [[ "$from" == "$image":* ]]; then
		deps+=( "docker-build.${from#$image:}" )
	fi

	cat <<EOB

boot2docker-$variant.iso: docker-build.$variant
	# TODO figure out a nice clean way we can be able to Ctrl+C this step
	#   constraints:
	#     - can't just use a bind mount since that won't work well against non-local daemons
	#     - "docker cp" is inconsistent wrt files vs directories (https://github.com/docker/docker/pull/13171 might help)
	#     - can't add "-t" because then output redirection doesn't work properly
	# if you need to cancel, use "docker ps" to find the container, and then use "docker kill" to stop it
	docker run --rm $image:$variant sh -c 'build-iso.sh >&2 && cat /tmp/docker.iso' > \$@
	@ls -lh \$@

docker-build.$variant: ${deps[*]}
	docker build -t $image:$variant -f \$< .
	@echo
	@docker images $image | awk 'NR == 1 || \$\$2 == "$variant" { print }'
	@echo
explore-$variant: docker-build.$variant
	docker run -it --rm $image:$variant
audit-$variant: docker-build.$variant
	docker run -it --rm $image:$variant sh -c 'audit-rootfs.sh 2>&1 | sort | less'
.PHONY: docker-build.$variant explore-$variant audit-$variant
EOB
done
