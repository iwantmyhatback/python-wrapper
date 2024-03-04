#!/usr/bin/env sh

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

REPO_ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "${REPO_ROOT_DIR}" || exit 1

. "${REPO_ROOT_DIR}/shell/sourceEnvironment.sh"

FULL_PYENV_LOCATION="${REPO_ROOT_DIR}/${PYENV_LOCATION}"

PREVIOUS_COMMIT=$(git rev-list HEAD -n 1)

if [ "${LOG_LEVEL}" != "DEBUG" ]; then
    QUIET="--quiet"
fi

if [ "${AUTO_UPDATE:-}" = 'TRUE' ]; then
    printf "[INFO]\t[GIT]\t Update git repository (Pull)\n"
    git pull "${QUIET}"
fi

if [ -z "$(docker images -q ${DOCKER_NAME}:latest 2> /dev/null)" ] || [ "${PREVIOUS_COMMIT}" != "$(git rev-list HEAD -n 1)" ] || [ "${FORCE_DOCKER_REBUILD:-}" = 'TRUE' ]; then
    [ "${FORCE_DOCKER_REBUILD:-}"  = 'TRUE' ] && printf "[INFO]\t[DOCKER] FORCE_DOCKER_REBUILD is active .......... Rebuilding image\n"
    [ "${FORCE_DOCKER_REBUILD:-}" != 'TRUE' ] && printf "[INFO]\t[DOCKER] Found changes to %s .......... Rebuilding image\n" "${DOCKER_NAME}"
    "${REPO_ROOT_DIR}/shell/buildImage.sh"
else
    printf "[INFO]\t[DOCKER] No changes to %s\n" "${DOCKER_NAME}"
    if [ -d "${FULL_PYENV_LOCATION}" ]; then
        printf "[INFO]\t[DOCKER] Clear existing virtual environment at %s\n" "${FULL_PYENV_LOCATION}"
        [ "$(command -v deactivate)" ] && deactivate
        rm -rf "${FULL_PYENV_LOCATION:?}"
    fi
fi

printf "[INFO]\t[DOCKER] Start the Docker run for %s:latest\n" "${DOCKER_NAME}"
docker run "${QUIET}" --env-file "${REPO_ROOT_DIR}/configuration/environment.properties" --rm --name "${DOCKER_NAME}" "${DOCKER_NAME}:latest" "${REPO_ROOT_DIR}/shell/run.sh"