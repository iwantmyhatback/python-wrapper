#!/usr/bin/env sh

# Shared helper functions for repository root detection and requirements hashing
# This file only defines functions — no side effects when sourced

# Resolve the repository root directory
# Uses git if available, otherwise falls back to script path calculation
# Prints the absolute path to stdout
helpers__resolve_repo_root() {
    if git rev-parse --show-toplevel > /dev/null 2>&1; then
        git rev-parse --show-toplevel
    else
        _full_0="$( readlink -f "${0}" )"
        # Calling scripts are nested 1 level down from the root
        _dir_basename="$( basename "$( dirname "$( readlink -f "${0}" )" )" )"
        _script_file="$( basename "$( readlink -f "${0}" )" )"
        _relative_0="${_dir_basename}/${_script_file}"
        printf '%s' "${_full_0%%"${_relative_0}"}"
    fi
}

# Portable SHA-256 calculation of requirements.txt
# Falls back through: sha256sum (Linux) -> shasum (macOS) -> openssl (universal)
# Prints the first 16 chars of the hash to stdout
helpers__calculate_requirements_sha() {
    if command -v sha256sum > /dev/null 2>&1; then
        _sha="$(sha256sum requirements.txt | awk '{print $1}')"
    elif command -v shasum > /dev/null 2>&1; then
        _sha="$(shasum -a 256 requirements.txt | awk '{print $1}')"
    elif command -v openssl > /dev/null 2>&1; then
        _sha="$(openssl dgst -sha256 requirements.txt | awk '{print $NF}')"
    else
        printf "[ERROR]\t[HELPER] No SHA-256 tool found (need sha256sum, shasum, or openssl)\n" >&2
        exit 1
    fi
    printf '%s' "${_sha}" | cut -c 1-16
}

# Resolve the full absolute path to the Python virtual environment directory
# Derives venv name from PYVENV_LOCATION config and requirements.txt hash
# Requires REPO_ROOT_DIR to be set
# Prints the absolute venv path to stdout
helpers__resolve_venv_path() {
    _short_sha="$(helpers__calculate_requirements_sha)"
    _venv_name="${PYVENV_LOCATION:-py_venv}_${_short_sha}"
    printf '%s' "${REPO_ROOT_DIR}/${_venv_name}"
}

# Export environment variables from configuration/environment.properties
# Skips comments and blank lines. No-ops if already sourced.
# Requires REPO_ROOT_DIR to be set
helpers__source_environment() {
    if [ -z "${ALREADY_SOURCED}" ]; then
        printf "[INFO]\t[SH_ENV] Exporting configuration/environment.properties variables:\n"
        while read -r VARIABLE || [ -n "${VARIABLE}" ]; do
            if [ "${VARIABLE%"${VARIABLE#?}"}" = "#" ] || [ "${VARIABLE}" = '' ]; then
                continue
            else
                printf "[INFO]\t[SH_ENV] >>\t %s\n" "${VARIABLE?}"
                export "${VARIABLE:?[ERROR] export failed in helpers__source_environment!}"
            fi
        done < "${REPO_ROOT_DIR}/configuration/environment.properties"

        export ALREADY_SOURCED=TRUE
    else
        printf "[INFO]\t[SH_ENV] Skipping additional sourcing because ALREADY_SOURCED is defined\n"
    fi
}

# Verify that uv is installed and available in PATH
# Exits with error and install instructions if not found
helpers__require_uv() {
    if ! command -v uv > /dev/null 2>&1; then
        printf "[ERROR]\t[  UV  ] uv is not installed or not in PATH\n" >&2
        printf "[ERROR]\t[  UV  ] Install: curl -LsSf https://astral.sh/uv/install.sh | sh\n" >&2
        printf "[ERROR]\t[  UV  ] Or:      brew install uv\n" >&2
        exit 1
    fi
}
