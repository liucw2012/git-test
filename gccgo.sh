#!/bin/bash

trap 'docker run --rm -v "$(pwd):/workspace" busybox chown -R "$(id -u):$(id -g)" /workspace' EXIT

# checkout the PR
git fetch origin +refs/pull/$PR/head:refs/remotes/origin/pr/$PR
git merge origin/pr/$PR


# run tests
docker build --rm --force-rm -f Dockerfile.gccgo -t docker:$(git rev-parse --short HEAD)-gccgo .
docker run --rm -t --privileged \
    -v "$WORKSPACE/bundles:/go/src/github.com/docker/docker/bundles" \
    -e GOMAXPROCS=1 --name docker-pr-gccgo$BUILD_NUMBER -e DOCKER_GRAPHDRIVER=vfs -e DOCKER_EXECDRIVER=native -e TIMEOUT=180m docker:$(git rev-parse --short HEAD)-gccgo hack/make.sh gccgo test-unit test-integration-cli

