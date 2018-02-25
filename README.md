# diesel-cli as an init container
[![build status](https://secure.travis-ci.org/clux/diesel-cli.svg)](http://travis-ci.org/clux/diesel-cli)
[![docker pulls](https://img.shields.io/docker/pulls/clux/diesel-cli.svg)](
https://hub.docker.com/r/clux/diesel-cli/)
[![docker image info](https://images.microbadger.com/badges/image/clux/diesel-cli.svg)](http://microbadger.com/images/clux/diesel-cli)
[![docker tag](https://images.microbadger.com/badges/version/clux/diesel-cli.svg)](https://hub.docker.com/r/clux/diesel-cli/tags/)

Needed a dockerised diesel cli to use as a migration [init container](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) for kubernetes, so here's a tiny one built with [muslrust](https://github.com/clux/muslrust).

Builds weekly on cron against latest stable rust, and latest released version of [diesel](https://crates.io/crates/diesel).

## Usage
Generally from kubernetes/swarm as an `initContainer`, or from CI to run migrations. It needs your committed migration files, so mount your repo dir as usual:

```sh
docker run --rm \
    -v "$PWD:/volume" \
    -w /volume \
    -e DATABASE_URL="${DATABASE_URL}" \
    -it clux/diesel-cli diesel migration run
```

If you're on a CI system, you might just get away with using `--net=host` if you're lazy.
