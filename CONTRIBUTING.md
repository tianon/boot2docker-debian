# Contributing to boot2docker

[![Build Status](https://travis-ci.org/docker/boot2docker.svg)](https://travis-ci.org/docker/boot2docker)

## Be Respectful

If you're not a maintainer of the boot2docker project, please try to refrain from making authoritative comments (especially misleading `LGTM`).  On the flip side, constructive comments contributing to useful dialog are welcome and encouraged.

## Commit Messages

It's recommended that commit messages can be applied against the following template and still be grammatically correct, but not strictly required:

	If applied, this commit will <message>

For example, if the commit message was `Fix file sharing bugs`:

	If applied, this commit will Fix file sharing bugs

or `Add rainbow features`:

	If applied, this commit will Add rainbow features

## Whitespace, Punctuation

Tabs for indentation.

`&&` and `||` at the beginning of lines, not at the end.

Single indentation for each level of "scope".

Alphabetizing where appropriate.

For example:

```Dockerfile
RUN some command \
	&& some other \
		command \
		with \
		useful \
		args \
	&& last command

RUN apt-get update && apt-get install -y --no-install-recommends \
		apackage \
		bpackage \
		cpackage \
		dpackage \
		zpackage \
		\
		unrelatedpackage1 \
		unrelatedpackage2 \
		unrelatedpackage3 \
	&& rm -rf /var/lib/apt/lists/*
```

## Building

There is a generated `Makefile` -- if you're using bash, tab completion should work properly.

Each "variant" is built from the corresponding `Dockerfile.<variant>` file.  For example, the `virtualbox` variant is built from `Dockerfile.virtualbox` into `boot2docker-virtualbox.iso`.

### `Makefile` targets

#### `make all`

This target (the default target if none is supplied) will build all the "release" ISOs (one per variant).

#### `make boot2docker-<variant>.iso`

This target will build the appropriate images and build/extract the ISO from the final result.

For example, `make boot2docker-virtualbox.iso` will `docker build -f Dockerfile.base .`, `docker build -f Dockerfile.docker .`, `docker build -f Dockerfile.virtualbox .`, followed by ISO building and extraction.

#### `make audit-<variant>`

This target will build the appropriate images and then open `less` to view a list of the files that would be included in the final ISO for the given variant.

#### `make explore-<variant>`

This target will build the appropriate images and then open a `bash` shell to facilitate exploration of the image that produces the given ISO variant.

### Customizing

To create your own variant, make a new file called `Dockerfile.myvariant` with contents similar to the following:

```Dockerfile
# choose an appropriate base -- one of the variants or "docker" is recommended
FROM dockercore/boot2docker:virtualbox

# steps to modify the image in whatever way you desire for your variant
RUN apt-get update && apt-get install -y --no-install-recommends \
		git \
		golang \
	&& rm -rf /var/lib/apt/lists/*
```

Then, use `make boot2docker-myvariant.iso` to build an ISO.
