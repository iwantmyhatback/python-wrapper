#!/usr/bin/env sh
set -e

# Delete existing Docker image and rebuild the image with current files
# Can be used when testing adhoc, but is also used by shell/run_docker.sh in deployments

# shellcheck disable=SC1091
. "$(dirname "$0")/helpers.sh"
REPO_ROOT_DIR="$(helpers__resolve_repo_root)"
cd "${REPO_ROOT_DIR}" || exit 1
helpers__source_environment

FULL_PYVENV_LOCATION="$(helpers__resolve_venv_path)"

if [ "${LOG_LEVEL}" != "DEBUG" ]; then
    QUIET="--quiet"
fi

if [ -d "${FULL_PYVENV_LOCATION}" ]; then
    printf "[INFO]\t[DOCKER] Clear existing virtual environment at %s\n" "${FULL_PYVENV_LOCATION}"
    [ -n "${VIRTUAL_ENV}" ] && deactivate 2>/dev/null || true
    rm -rf "${FULL_PYVENV_LOCATION:?}"
fi

if [ "${AUTO_UPDATE}" = 'TRUE' ]; then
    printf "[INFO]\t[DOCKER] Update Docker Python image (Pull)\n"
    # shellcheck disable=SC2086
    docker pull ${QUIET} python:latest
fi

DOCKER_NAME="${DOCKER_NAME:-python_wrapper}"

printf "[INFO]\t[DOCKER] Remove old %s image\n" "${DOCKER_NAME}"
docker image rm "${DOCKER_NAME}" --force > /dev/null 2>&1 || true

printf "[INFO]\t[DOCKER] Build new %s image\n" "${DOCKER_NAME}"

# shellcheck disable=SC2086
docker build ${QUIET} --build-arg PYVENV_LOCATION="${PYVENV_LOCATION}" --build-arg DIRNAME="${REPO_ROOT_DIR}" -t "${DOCKER_NAME}" ./
