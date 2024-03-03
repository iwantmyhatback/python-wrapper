#! /usr/bin/env sh

# Delete existing Docker image and rebuild the image with current files
# Can be used when testing adhoc, but is also used by shell/runDocker.sh in deployments

REPO_ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "${REPO_ROOT_DIR}" || exit

if [ -z "${ALREADY_SOURCED:-}" ]; then
    . "${REPO_ROOT_DIR}/shell/sourceEnvironment.sh"
else
    echo "[INFO] [SH_ENV] Skipping additional sourcing because ALREADY_SOURCED is defined"
fi

FULL_PYENV_LOCATION="${REPO_ROOT_DIR}/${PYENV_LOCATION}"

if [ -d "${FULL_PYENV_LOCATION}" ]; then
    echo "[INFO] [DOCKER] Clear existing virtual environment at ${REPO_ROOT_DIR}/${PYENV_LOCATION}"
    [ "$(command -v deactivate)" ] && deactivate
    rm -rf "${FULL_PYENV_LOCATION:?}"
fi

echo "[INFO] [DOCKER] Start Docker Python image update (Pull)"
docker pull python

echo "[INFO] [DOCKER] Remove old ${DOCKER_NAME} image"
docker image rm "${DOCKER_NAME}"

echo "[INFO] [DOCKER] Build new ${DOCKER_NAME} image"
docker build --build-arg PYENV_LOCATION="${PYENV_LOCATION}" --build-arg DIRNAME="${REPO_ROOT_DIR}" -t "${DOCKER_NAME}" ./