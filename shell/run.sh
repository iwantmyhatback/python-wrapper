#!/usr/bin/env sh
set -e

# Perform the entire Python execution routine
# Includes:
#   Ensuring script execution is within the repository
#   Export the environment variables set in configuration/environment.properties
#   Perform Pre-Python dependency checks and installed
#   Then execute the Python routine

# shellcheck disable=SC1091
. "$(dirname "$0")/helpers.sh"

REPO_ROOT_DIR="$(helpers__resolve_repo_root)"
cd "${REPO_ROOT_DIR}" || exit 1

helpers__source_environment
helpers__require_uv

# shellcheck disable=SC1091
. "${REPO_ROOT_DIR}/shell/pre_run.sh"

FULL_PYVENV_LOCATION="$(helpers__resolve_venv_path)"

if [ "${LOG_LEVEL}" != "DEBUG" ]; then
    QUIET="--quiet"
fi

if [ -d "${FULL_PYVENV_LOCATION}" ] && ! [ "${FORCE_VENV_REBUILD}" = 'TRUE' ]; then
    printf '[INFO]\t[PY_ENV] "%s" does exist\n' "${FULL_PYVENV_LOCATION}"
    # shellcheck disable=SC1091
    . "${FULL_PYVENV_LOCATION}/bin/activate"
fi

if [ ! -d "${FULL_PYVENV_LOCATION}" ] || [ "${FORCE_VENV_REBUILD}" = 'TRUE' ]; then
    printf '[INFO]\t[PY_ENV] Virtual Environment: "%s" does not exist\n' "${FULL_PYVENV_LOCATION}"
    # shellcheck disable=SC2086
    uv venv ${QUIET} "${FULL_PYVENV_LOCATION}"
    printf '[INFO]\t[PY_ENV] Virtual Environment: "%s" Created\n' "${FULL_PYVENV_LOCATION}"
    # shellcheck disable=SC1091
    . "${FULL_PYVENV_LOCATION}/bin/activate"
    printf '[INFO]\t[PY_ENV] Virtual Environment: "%s" Activated\n' "${FULL_PYVENV_LOCATION}"
fi

# shellcheck disable=SC2086
uv pip install ${QUIET} --requirement "${REPO_ROOT_DIR}/requirements.txt"

if [ "${REFREEZE_REQUIREMENTS}" = 'TRUE' ]; then
    printf "[INFO]\t[PY_ENV] Re-Freezing the Requirements file\n"
    uv pip freeze > "${REPO_ROOT_DIR}/requirements.txt.tmp"
    mv "${REPO_ROOT_DIR}/requirements.txt.tmp" "${REPO_ROOT_DIR}/requirements.txt"
fi


"${FULL_PYVENV_LOCATION}/bin/python" -Bu "${REPO_ROOT_DIR}/python/main.py" "${@}"

# shellcheck disable=SC1091
. "${REPO_ROOT_DIR}/shell/post_run.sh"
