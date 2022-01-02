#!/bin/bash

export FROM_CI=${FROM_CI:-false}

if [[ "${FROM_CI}" == "true" ]]; then
    export DOCKERHUB_USERNAME="${DOCKERHUB_USERNAME:-}"
    export DOCKERHUB_PASSWORD="${DOCKERHUB_PASSWORD:-}"
    export DOCKER_CLI_EXPERIMENTAL=enabled
    export GITHUB_TOKEN="${GITHUB_TOKEN:-}"
    export GITHUB_USERNAME="${GITHUB_USERNAME:-}"
    docker buildx create --name builder-multi
    docker buildx use builder-multi
    if [[ -n ${DOCKERHUB_USERNAME} ]] && [[ ${DOCKERHUB_PASSWORD} ]]; then
        echo "${DOCKERHUB_PASSWORD}" | docker login --username "${DOCKERHUB_USERNAME}" --password-stdin
        docker buildx build --platform linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64/v8 --push -t "${DOCKERHUB_USERNAME}"/samba:latest .
        docker logout
    fi
    if [[ -n "${GITHUB_TOKEN}" ]]; then
        echo "${GITHUB_TOKEN}" | docker login ghcr.io --username "${GITHUB_USERNAME}" --password-stdin
        docker buildx build --platform linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64/v8 --push -t ghcr.io/"${GITHUB_USERNAME}"/samba:latest .
        docker logout
    fi    
else
    docker build -t samba:latest .
fi

