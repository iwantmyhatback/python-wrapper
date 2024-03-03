#!/usr/bin/env sh

# Perform the entire Check and Email routine and all the Deployment tasks
# Includes:
#   Ensuring script execution is within the repository
#   Getting repository changes
#   Rebuilding Docker image if there were any git changes
#   Run the shell/main.sh script in a disposable docker container

REPO_ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "${REPO_ROOT_DIR}" || exit

. "${REPO_ROOT_DIR}/shell/sourceEnvironment.sh"

FULL_PYENV_LOCATION="${REPO_ROOT_DIR}/${PYENV_LOCATION}"

echo "[INFO] [GIT] Start git repository update (Pull)"
PREVIOUS_COMMIT=$(git rev-list HEAD -n 1)
git pull

if [ "${PREVIOUS_COMMIT}" != "$(git rev-list HEAD -n 1)" ] || [ "${FORCE_DOCKER_REBUILD:-}" = 'TRUE' ]; then
    [ "${FORCE_DOCKER_REBUILD:-}"  = 'TRUE' ] && echo "[INFO] [DOCKER] FORCE_DOCKER_REBUILD is active .......... Rebuilding image"
    [ "${FORCE_DOCKER_REBUILD:-}" != 'TRUE' ] && echo "[INFO] [DOCKER] Found changes to ${DOCKER_NAME} .......... Rebuilding image"
    "${REPO_ROOT_DIR}/shell/buildImage.sh"
else
    echo "[INFO] [DOCKER] No changes to ${DOCKER_NAME}"
fi

if [ -d "${FULL_PYENV_LOCATION}" ]; then
    echo "[INFO] [DOCKER] Clear existing virtual environment at ${REPO_ROOT_DIR}/${PYENV_LOCATION}"
    [ "$(command -v deactivate)" ] && deactivate
    rm -rf "${FULL_PYENV_LOCATION:?}"
fi


echo "[INFO] [DOCKER] Start the Docker run for ${DOCKER_NAME}:latest"
docker run --env-file "${REPO_ROOT_DIR}/configuration/environment.properties" --rm --name "${DOCKER_NAME}" "${DOCKER_NAME}:latest" "${REPO_ROOT_DIR}/shell/main.sh"