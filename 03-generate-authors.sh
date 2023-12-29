#!/bin/bash

set -e

PROJECTSFILE_DEFAULT="work/projects.txt"
PROJECTSFILE_PATH="${1:-$PROJECTSFILE_DEFAULT}"
PROJECTSFILE="$(basename "${PROJECTSFILE_PATH}")"
WORK_DIR="$(dirname "${PROJECTSFILE_PATH}")"
AUTHORS_FILE="authors.txt"
cd "${WORK_DIR}"

if [ ! -f ${PROJECTSFILE} ]
then
    echo "${PROJECTSFILE_PATH} is missing. Run 01-get-projects.sh first"
    exit 1
fi
while read PROJECT; do
    cd ${PROJECT}
    echo "Project '${PROJECT}'"
    rm -f ${AUTHORS_FILE}
    for d in */;
        do echo "- ${d%/}";
        rm -f ${AUTHORS_FILE}
        cd $d
        git log --all --format='%aN <%cE>' | sort -u >> ${AUTHORS_FILE}
        cat ${AUTHORS_FILE} >> ../${AUTHORS_FILE}
        cd ..
    done
    cd ..
done < ${PROJECTSFILE}

find . -type f -name "${AUTHORS_FILE}" -exec cat {} + | sort -u > ${AUTHORS_FILE}
echo
echo "Created ${AUTHORS_FILE} in ${WORK_DIR}:"
cat authors.txt
echo "Transform it into git-mailmap format and run 04-migrate-bare-to-github.sh"
cd ..
