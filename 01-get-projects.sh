#!/bin/bash

set -e

USER=${1}
TOKEN=${2}
BASE_URL=${3}
PROJECTSFILE_DEFAULT="work/projects.txt"
PROJECTSFILE_PATH="${4:-$PROJECTSFILE_DEFAULT}"
echo "Using ${PROJECTSFILE_PATH}"
PROJECTSFILE="$(basename "${PROJECTSFILE_PATH}")"
WORK_DIR="$(dirname "${PROJECTSFILE_PATH}")"

rm -rf "$PROJECTSFILE_PATH"
mkdir -p "${WORK_DIR}"
cd "${WORK_DIR}"

curl -u "$USER:$TOKEN" "${BASE_URL}/rest/api/1.0/projects" | jq -r '.values[] | (.key)' > "${PROJECTSFILE}"
echo "Created '${PROJECTSFILE_PATH}' with the following content:"
cat "${PROJECTSFILE}"

cd ..