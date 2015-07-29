# boot2docker

This is the newly re-imagined boot2docker, based on Debian for stability and maintainability.  If you are looking for ["boot2docker (Legacy)", see github.com/boot2docker/boot2docker](https://github.com/boot2docker/boot2docker).

This is intended to be used with [Docker Machine](https://docs.docker.com/machine/), but should be mostly usable outside that context as well.  Be warned that the largest unformatted disk found during boot _will_ be partitioned and formatted for use unless a partition with the label `data` is found (which will be used automatically instead).

## Building and Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for more information about how to build ISOs (stock or custom), and especially information about how to contribute effectively.
