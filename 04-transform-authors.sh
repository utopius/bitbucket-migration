#!/bin/bash

set -e

PROJECTSFILE_DEFAULT="work/projects.txt"
PROJECTSFILE_PATH="${1:-$PROJECTSFILE_DEFAULT}"
PROJECTSFILE="$(basename "${PROJECTSFILE_PATH}")"
WORK_DIR="$(dirname "${PROJECTSFILE_PATH}")"
AUTHORS_FILE="../../mailmap.txt"
cd "${WORK_DIR}"

wget https://raw.githubusercontent.com/newren/git-filter-repo/main/git-filter-repo

if [ ! -f ${PROJECTSFILE} ]
then
    echo "${PROJECTSFILE} is missing. Run get_projects.sh first"
    exit 1
fi
while read PROJECT; do
    cd ${PROJECT}
    echo "Project '${PROJECT}'"
    for d in */;
        do
        TARGET="${d%/}"
        echo "- ${TARGET}";
        cd ${TARGET}
        git shortlog -sne --all
        ../../git-filter-repo --mailmap ${AUTHORS_FILE} --force
        git shortlog -sne --all
        cd ..
    done
    cd ..
done < ${PROJECTSFILE}
cd ..
