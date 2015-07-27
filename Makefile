.depends: Dockerfile.*
	./gen-makefile.sh > $@

sinclude .depends
