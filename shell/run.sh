#! /usr/bin/env sh

# Perform the entire Python execution routine
# Includes:
#   Ensuring script execution is within the repository
#   Export the environment variables set in configuration/environment.properties
#   Perform Pre-Python dependency checks and installed
#   Then execute the Python routine

REPO_ROOT_DIR="$(git rev-parse --show-toplevel)"
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
    printf "[INFO]\t[PY_ENV] %s does exist\n" "${FULL_PYENV_LOCATION}"
    # shellcheck disable=SC1091
    . "${FULL_PYENV_LOCATION}/bin/activate"
fi

if [ ! -d "${FULL_PYENV_LOCATION}" ]; then
    printf "[INFO]\t[PY_ENV] %s does not exist\n" "${FULL_PYENV_LOCATION}"
    /usr/bin/env python3 -m venv "${FULL_PYENV_LOCATION}"
    # shellcheck disable=SC1091
    . "${FULL_PYENV_LOCATION}/bin/activate"
    # shellcheck disable=SC2086
    "${FULL_PYENV_LOCATION}/bin/python" -m pip install ${QUIET} --upgrade pip
fi

# shellcheck disable=SC2086
"${FULL_PYENV_LOCATION}/bin/python" -m pip install ${QUIET} --requirement "${REPO_ROOT_DIR}/requirements.txt"

if [ "${REFREEZE_REQUIREMENTS:-}" = 'TRUE' ]; then
    printf "[INFO]\t[PY_ENV] Re-Freezing the Requirements file\n"
    "${PYENV_LOCATION}/bin/python" -m pip freeze > "${REPO_ROOT_DIR}/requirements.txt"
fi


"${FULL_PYENV_LOCATION}/bin/python" -Bu "${REPO_ROOT_DIR}/python/main.py"