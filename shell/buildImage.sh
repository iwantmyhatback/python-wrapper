#! /usr/bin/env sh

# Delete existing Docker image and rebuild the image with current files
# Can be used when testing adhoc, but is also used by shell/runDocker.sh in deployments

if git rev-parse --show-toplevel 2>&1 /dev/null; then
    REPO_ROOT_DIR="$(git rev-parse --show-toplevel)"
else
    FULL_0="$( readlink -f "${0}" )"
    # Needed because this script is nested 1 level down from the root
    SCRIPT_DIR_BASENAME="$( basename "$( dirname "$( readlink -f "${0}" )" )" )"
    SCRIPT_FILE="$( basename "$( readlink -f "${0}" )" )"
    RELATIVE_0="${SCRIPT_DIR_BASENAME}/${SCRIPT_FILE}"
    REPO_ROOT_DIR="${FULL_0%%"${RELATIVE_0}"}"
fi
cd "${REPO_ROOT_DIR}" || exit 1

if [ -z "${ALREADY_SOURCED:-}" ]; then
    # shellcheck disable=SC1091
    . "${REPO_ROOT_DIR}/shell/sourceEnvironment.sh"
else
    printf "[INFO]\t[SH_ENV] Skipping additional sourcing because ALREADY_SOURCED is defined\n"
fi

FULL_PYENV_LOCATION="${REPO_ROOT_DIR}/${PYENV_LOCATION}"

if [ "${LOG_LEVEL}" != "DEBUG" ]; then
    QUIET="--quiet"
fi

if [ -d "${FULL_PYENV_LOCATION}" ]; then
    printf "[INFO]\t[DOCKER] Clear existing virtual environment at %s\n" "${FULL_PYENV_LOCATION}"
    [ "$(command -v deactivate)" ] && deactivate
    rm -rf "${FULL_PYENV_LOCATION:?}"
fi

if [ "${AUTO_UPDATE:-}" = 'TRUE' ]; then
    printf "[INFO]\t[DOCKER] Update Docker Python image (Pull)\n"
    docker pull "${QUIET}" python:latest
fi

printf "[INFO]\t[DOCKER] Remove old %s image\n" "${DOCKER_NAME}"
docker image rm "${DOCKER_NAME}"

printf "[INFO]\t[DOCKER] Build new %s image\n" "${DOCKER_NAME}"
docker build "${QUIET}" --build-arg PYENV_LOCATION="${PYENV_LOCATION}" --build-arg DIRNAME="${REPO_ROOT_DIR}" -t "${DOCKER_NAME}" ./