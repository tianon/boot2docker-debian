.depends: gen-makefile.sh Dockerfile.*
	./$< > $@

sinclude .depends

clean:
	rm .depends
	rm -vf boot2docker-*.iso
.PHONY: clean
