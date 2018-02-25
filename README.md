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

You can probably get away with using `--net=host` to avoid figuring out the database ip. See the [webapp-rs circle config](https://github.com/clux/webapp-rs/blob/7d16da909f9b411ce6620186d1836ff9cb0e5c24/.circleci/config.yml#L11-L18) for further setup ideas.

### Kubernetes
Planned usage.
Add your migrations to a container based on this one:

```
FROM clux/diesel-cli

ADD migrations /
```

then run that container as part of [helm lifecycle hooks](https://github.com/kubernetes/helm/blob/master/docs/charts_hooks.md#the-available-hooks) or as an [init container](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) on deploy illustrated here:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
spec:
  containers:
  - name: myapp-container
    image: myapp-image
  initContainers:
  - name: migrate-db
    image: your-diesel-cli
    command: ['diesel', 'migration', 'run']
    env:
    - name: DATABASE_URL
      value: "postgres://clux:foo@10.10.10.10/mydb"
```

The `initContainers` use is the least interesting, because most languages can do a 'run pending migration' step as part of their startup process. However, coordinating a rollback can be harder because the app/pod is often just killed without any indication of why.

If you had accidentally done a breaking migration for this upgrade, then you would need to revert your migration as well, otherwise your entire deployment could be broken.

Thus, a `pre-rollback` lifecycle hook has potential here. You could use this container to run `diesel migration revert` in a kubernetes `Job` bound to the helm hook.

Ideally, [you avoid backwards incompatible migrations](https://github.com/elafarge/blog-articles/blob/master/01-no-downtime-migrations/zero-downtime-database-migrations.md), but this can provide some safety when someone forgets to do this.
