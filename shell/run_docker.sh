#!/usr/bin/env sh
set -e

# Perform the script execution and all the container tasks
# Includes:
#   Ensuring script execution is within the repository
#   Getting repository changes
#   Rebuilding Docker image if there were any git changes
#   Run the shell/run.sh script in a disposable docker container

if [ ! "$(command -v docker)" ]; then
    printf "[ERROR]\t[DOCKER] There is no \"docker\" command in the PATH!\n"
    exit 1
fi

# shellcheck disable=SC1091
. "$(dirname "$0")/helpers.sh"
REPO_ROOT_DIR="$(helpers__resolve_repo_root)"
cd "${REPO_ROOT_DIR}" || exit 1
helpers__source_environment

FULL_PYVENV_LOCATION="$(helpers__resolve_venv_path)"

PREVIOUS_COMMIT=$(git rev-list HEAD -n 1)

if [ "${LOG_LEVEL}" != "DEBUG" ]; then
    QUIET="--quiet"
fi

if [ "${AUTO_UPDATE}" = 'TRUE' ]; then
    printf "[INFO]\t[ GIT  ]    Update git repository (Pull)\n"
    # shellcheck disable=SC2086
    git pull ${QUIET}
fi

DOCKER_NAME="${DOCKER_NAME:-python_wrapper}"

# shellcheck disable=SC2086
if [ -z "$(docker images -q ${DOCKER_NAME}:latest 2> /dev/null)" ] || [ "${PREVIOUS_COMMIT}" != "$(git rev-list HEAD -n 1)" ] || [ "${FORCE_DOCKER_REBUILD}" = 'TRUE' ]; then
    if [ "${FORCE_DOCKER_REBUILD}" = 'TRUE' ]; then
        printf "[INFO]\t[DOCKER] FORCE_DOCKER_REBUILD is active .......... Rebuilding image\n"
    else
        printf "[INFO]\t[DOCKER] Found changes to %s .......... Rebuilding image\n" "${DOCKER_NAME}"
    fi
    "${REPO_ROOT_DIR}/shell/build_image.sh"
else
    printf "[INFO]\t[DOCKER] No changes to %s\n" "${DOCKER_NAME}"
    if [ -d "${FULL_PYVENV_LOCATION}" ]; then
        printf "[INFO]\t[DOCKER] Clear existing virtual environment at %s\n" "${FULL_PYVENV_LOCATION}"
        [ -n "${VIRTUAL_ENV}" ] && deactivate 2>/dev/null || true
        rm -rf "${FULL_PYVENV_LOCATION:?}"
    fi
fi

printf "[INFO]\t[DOCKER] Start the Docker run for %s:latest\n" "${DOCKER_NAME}"
# shellcheck disable=SC2086
docker run ${QUIET} --env-file "${REPO_ROOT_DIR}/configuration/environment.properties" --rm --name "${DOCKER_NAME}" "${DOCKER_NAME}:latest" "${REPO_ROOT_DIR}/shell/run.sh" "${@}"
