# boot2docker

This is the newly re-imagined boot2docker, based on Debian for stability and maintainability.  If you are looking for the [legacy boot2docker, see github.com/boot2docker/boot2docker](https://github.com/boot2docker/boot2docker).

This is intended to be used with [Docker Machine](https://docs.docker.com/machine/), but should be mostly usable outside that context as well.  Be warned that the largest unformatted disk found during boot _will_ be partitioned and formatted for use unless a partition with the label `data` is found (which will be used automatically instead).

## Building

[![Build Status](https://travis-ci.org/docker/boot2docker.svg)](https://travis-ci.org/docker/boot2docker)
