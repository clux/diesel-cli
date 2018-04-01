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

then run that container as part of [helm lifecycle hooks](https://github.com/kubernetes/helm/blob/master/docs/charts_hooks.md#the-available-hooks) against a `Deployment`.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: "{{.Release.Name}}"
  labels:
    heritage: {{.Release.Service | quote }}
    release: {{.Release.Name | quote }}
    chart: "{{.Chart.Name}}-{{.Chart.Version}}"
  annotations:
    "helm.sh/hook": pre-install
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": hook-succeeded
spec:
  template:
    metadata:
      name: "{{.Release.Name}}"
      labels:
        heritage: {{.Release.Service | quote }}
        release: {{.Release.Name | quote }}
        chart: "{{.Chart.Name}}-{{.Chart.Version}}"
    spec:
      restartPolicy: Never
      containers:
      - name: post-install-job
        image: your-diesel-cli
        command: ['diesel', 'migration', 'run']
        env:
        - name: DATABASE_URL
          value: "postgres://clux:foo@10.10.10.10/mydb"
```

This should work if [you avoid backwards incompatible migrations](https://github.com/elafarge/blog-articles/blob/master/01-no-downtime-migrations/zero-downtime-database-migrations.md), and it avoids races with multiple pods attempting db migrations at the same time during kube rolling updates.
