# diesel-cli migration container
[![build status](https://secure.travis-ci.org/clux/diesel-cli.svg)](http://travis-ci.org/clux/diesel-cli)
[![docker pulls](https://img.shields.io/docker/pulls/clux/diesel-cli.svg)](
https://hub.docker.com/r/clux/diesel-cli/)
[![docker image info](https://images.microbadger.com/badges/image/clux/diesel-cli.svg)](http://microbadger.com/images/clux/diesel-cli)
[![docker tag](https://images.microbadger.com/badges/version/clux/diesel-cli.svg)](https://hub.docker.com/r/clux/diesel-cli/tags/)

Needed a dockerised diesel cli to use as a migration container for CI and Kubernetes, so here's a ~12MB one built with [muslrust](https://github.com/clux/muslrust).

Builds weekly on cron against latest stable rust, and latest released version of [diesel](https://crates.io/crates/diesel).

## Usage
### CI
You can use this on a docker based CI to run migrations, mounting your migration files directly:

```sh
docker run --rm \
    -v "$PWD:/volume" \
    -w /volume \
    -e DATABASE_URL="${DATABASE_URL}" \
    -it clux/diesel-cli diesel migration run
```

### Kubernetes
Don't run migrations as part of lifecycle hooks or helm hooks. It's way more complex than inlining a call to the [diesel_migrations crate](https://github.com/diesel-rs/diesel/tree/master/diesel_migrations).
