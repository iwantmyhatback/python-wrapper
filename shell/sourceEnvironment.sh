#! /usr/bin/env sh

# Export the environment variables set in configuration/environment.properties
# and set the indicator that the importing has been done to prevent redundant executions

REPO_ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "${REPO_ROOT_DIR}" || exit 1

printf "[INFO] [SH_ENV] Introducting configuration/environment.properties variables:"
while read -r VARIABLE; do
    if [ "${VARIABLE%"${VARIABLE#?}"}" = "#" ] || [ "${VARIABLE}" = '' ]; then
        continue
    else
        printf "[INFO] [SH_ENV] %s" "${VARIABLE?}"
        export "${VARIABLE?}"
    fi
done < "${REPO_ROOT_DIR}/configuration/environment.properties"

export ALREADY_SOURCED=TRUE