#! /usr/bin/env sh

# Export the environment variables set in configuration/environment.properties
# and set the indicator that the importing has been done to prevent redundant executions

REPO_ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "${REPO_ROOT_DIR}" || exit 1

printf "[INFO]\t[SH_ENV] Exporting configuration/environment.properties variables:\n"
while read -r VARIABLE; do
    if [ "${VARIABLE%"${VARIABLE#?}"}" = "#" ] || [ "${VARIABLE}" = '' ]; then
        continue
    else
        printf "[INFO]\t[SH_ENV] >> %s\n" "${VARIABLE?}"
        export "${VARIABLE?}"
    fi
done < "${REPO_ROOT_DIR}/configuration/environment.properties"

export ALREADY_SOURCED=TRUE