#! /usr/bin/env sh

# Delete existing Docker image and rebuild the image with current files
# Can be used when testing adhoc, but is also used by shell/runDocker.sh in deployments

REPO_ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "${REPO_ROOT_DIR}" || exit 1

if [ -z "${ALREADY_SOURCED:-}" ]; then
    . "${REPO_ROOT_DIR}/shell/sourceEnvironment.sh"
else
    printf "[INFO]\t[SH_ENV] Skipping additional sourcing because ALREADY_SOURCED is defined\n"
fi

FULL_PYENV_LOCATION="${REPO_ROOT_DIR}/${PYENV_LOCATION}"

if [ -d "${FULL_PYENV_LOCATION}" ]; then
    printf "[INFO]\t[DOCKER] Clear existing virtual environment at %s\n" "${FULL_PYENV_LOCATION}"
    [ "$(command -v deactivate)" ] && deactivate
    rm -rf "${FULL_PYENV_LOCATION:?}"
fi

printf "[INFO]\t[DOCKER] Start Docker Python image update (Pull)\n"
docker pull python:latest

printf "[INFO]\t[DOCKER] Remove old %s image\n" "${DOCKER_NAME}"
docker image rm "${DOCKER_NAME}"

printf "[INFO]\t[DOCKER] Build new %s image\n" "${DOCKER_NAME}"
docker build --build-arg PYENV_LOCATION="${PYENV_LOCATION}" --build-arg DIRNAME="${REPO_ROOT_DIR}" -t "${DOCKER_NAME}" ./