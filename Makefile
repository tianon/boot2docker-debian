.depends: Dockerfile.*
	./gen-makefile.sh > $@

sinclude .depends

clean:
	rm .depends
	rm -vf boot2docker-*.iso
.PHONY: clean
