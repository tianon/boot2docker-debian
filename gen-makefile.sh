#!/bin/bash
set -e

cd "$(dirname "$BASH_SOURCE")"

variants=( Dockerfile.* )
variants=( "${variants[@]#Dockerfile.}" )
image='dockercore/boot2docker'

echo -n 'all:'
for variant in "${variants[@]}"; do
	echo -n " boot2docker-$variant.iso"
done
echo
cat <<'EOB'
	@echo; echo
	@ls -lh $^
.PHONY: all

clean:
	rm -v boot2docker-*.iso
.PHONY: clean
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
	docker run --rm $image:$variant sh -c 'build-iso.sh >&2 && cat /tmp/docker.iso' > \$@
	@ls -lh \$@

docker-build.$variant: ${deps[*]}
	docker build -t $image:$variant -f \$< .
	@echo
	@docker images $image | awk 'NR == 1 || \$\$2 == "$variant" { print }'
	@echo
.PHONY: docker-build.$variant
EOB
done
