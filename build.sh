#!/bin/bash

export FROM_CI=${FROM_CI:-false}

if [[ "${FROM_CI}" == "true" ]]; then
    export DOCKERHUB_USERNAME="${DOCKERHUB_USERNAME:-}"
    export DOCKERHUB_PASSWORD="${DOCKERHUB_PASSWORD:-}"
    export DOCKER_CLI_EXPERIMENTAL=enabled
    export GITHUB_TOKEN="${GITHUB_TOKEN}"
    docker buildx create --name builder-multi
    docker buildx use builder-multi
    if [[ -n ${DOCKERHUB_USERNAME} ]] && [[ ${DOCKERHUB_PASSWORD} ]]; then
        echo "${DOCKERHUB_PASSWORD}" | docker login --username cruizba --password-stdin
        docker buildx build --platform linux/arm,linux/arm64,linux/amd64 --push -t cruizba/samba:latest .
        docker logout
    fi
    if [[ -n "${GITHUB_TOKEN}" ]]; then
        echo "${GITHUB_TOKEN}" | docker login ghcr.io --username cruizba --password-stdin
        docker buildx build --platform linux/arm,linux/arm64,linux/amd64 --push -t ghcr.io/cruizba/samba:latest .
        docker logout
    fi    
else
    docker build -t cruizba/samba:latest .
fi

