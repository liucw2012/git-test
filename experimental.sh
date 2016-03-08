#!/bin/bash

trap 'docker run --rm -v "$(pwd):/workspace" busybox chown -R "$(id -u):$(id -g)" /workspace' EXIT

# checkout the PR
git fetch origin +refs/pull/$PR/head:refs/remotes/origin/pr/$PR
git merge origin/pr/$PR


# run tests
docker build --rm --force-rm -t docker:$(git rev-parse --short HEAD)-exp .
docker run --rm -t --privileged \
    -v "$WORKSPACE/bundles:/go/src/github.com/docker/docker/bundles" \
    -e DOCKER_EXPERIMENTAL=y --name docker-pr-exp$BUILD_NUMBER -e DOCKER_GRAPHDRIVER=vfs -e DOCKER_EXECDRIVER=native -e TIMEOUT=120m docker:$(git rev-parse --short HEAD)-exp hack/make.sh

