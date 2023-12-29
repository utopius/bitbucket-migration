#!/bin/bash

set -e

USER=${1}
TOKEN=${2}
BASE_URL=${3}
PROJECTSFILE_DEFAULT="work/projects.txt"
PROJECTSFILE_PATH="${4:-$PROJECTSFILE_DEFAULT}"
PROJECTSFILE="$(basename "${PROJECTSFILE_PATH}")"
WORK_DIR="$(dirname "${PROJECTSFILE_PATH}")"
cd "${WORK_DIR}"

if [ ! -f "${PROJECTSFILE}" ]
then
    echo "${PROJECTSFILE_PATH} is missing. Run 01-get-projects.sh first"
    exit 1
fi

while read PROJECT; do
    echo "Project '$PROJECT'"

    rm -rf "$PROJECT" && mkdir "$PROJECT"
    cd $PROJECT

    URL="${BASE_URL}/rest/api/1.0/projects/${PROJECT}/repos/\?limit=1000"

    echo "Fetching repos in '${PROJECT}'..." && echo
    curl -u "$USER:$TOKEN" "${URL}" | jq '[ .values[] | { slug:.slug, links:.links.clone[] } | select(.links.name=="ssh") | { slug:.slug, url:.links.href }]' > repos.json
    while read -r slug
    do
        read -r url
        NAME=${slug}
        MIRROR="${slug}"
        MIRROR_CLONE="${slug}-clone"
        TARGET="migrated-${slug}"
        echo && echo "Cloning '${NAME}' from '${url}' with '--mirror'..."
        git clone --mirror ${url} ${MIRROR}
        cd "${MIRROR}"
        git remote remove origin
        echo && echo "Cloned '${NAME}' and removed origin '${url}'"
        cd ..
    done < <( jq -r '.[] | (.slug, .url)' repos.json)
    cd ..
done < "${PROJECTSFILE}"
cd ..
