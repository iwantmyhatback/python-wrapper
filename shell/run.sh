#! /usr/bin/env sh

# Perform the entire Check and Email routine
# Includes:
#   Ensuring script execution is within the repository
#   Export the environment variables set in configuration/environment.properties
#   Perform Pre-Python dependency checks and installed
#   Then execute the Python routine

REPO_ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "${REPO_ROOT_DIR}" || exit

if [ -z "${ALREADY_SOURCED:-}" ]; then
    . "${REPO_ROOT_DIR}/shell/sourceEnvironment.sh"
else
    echo "[INFO] [SH_ENV] Skipping additional sourcing because ALREADY_SOURCED is defined"
fi
    
if [ "${PYTHON_LOG_LEVEL}" != "DEBUG" ]; then
    QUIET="--quiet"
fi

FULL_PYENV_LOCATION="${REPO_ROOT_DIR}/${PYENV_LOCATION}"

if [ -d "${FULL_PYENV_LOCATION}" ]; then
    echo "[INFO] [PY_ENV] ${FULL_PYENV_LOCATION} does exist."
    . "${FULL_PYENV_LOCATION}/bin/activate"
fi

if [ ! -d "${FULL_PYENV_LOCATION}" ]; then
    echo "[INFO] [PY_ENV] ${FULL_PYENV_LOCATION} does not exist"
    /usr/bin/env python3 -m venv "${FULL_PYENV_LOCATION}"
    . "${FULL_PYENV_LOCATION}/bin/activate"
    "${FULL_PYENV_LOCATION}/bin/python" -m pip install ${QUIET} --upgrade pip
fi

. "${FULL_PYENV_LOCATION}/bin/activate"

"${FULL_PYENV_LOCATION}/bin/python" -m pip install ${QUIET} --requirement "${REPO_ROOT_DIR}/requirements.txt"
# "${PYENV_LOCATION}/bin/python" -m pip freeze > "${REPO_ROOT_DIR}/requirements.txt"

"${FULL_PYENV_LOCATION}/bin/python" -Bu "${REPO_ROOT_DIR}/python/main.py"