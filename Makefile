NAME=diesel-cli
VERSION=$(shell git rev-parse HEAD)
REPO=clux

build:
	docker build -t $(REPO)/$(NAME):$(VERSION) .

version:
	docker run -t $(REPO)/$(NAME):$(VERSION) diesel -V | awk '{print $$2}' > version

tag-latest: build
	docker tag $(REPO)/$(NAME):$(VERSION) $(REPO)/$(NAME):latest
	docker push $(REPO)/$(NAME):latest

tag-semver: build version
	if curl -sSL https://registry.hub.docker.com/v1/repositories/$(REPO)/$(NAME)/tags | jq -r ".[].name" | grep -q $(SEMVER_VERSION); then \
		echo "Tag $(SEMVER_VERSION) already exists" && exit 1 ;\
	fi
	docker tag $(REPO)/$(NAME):$(VERSION) $(REPO)/$(NAME):$(shell cat version)
	docker push $(REPO)/$(NAME):$(shell cat version)
