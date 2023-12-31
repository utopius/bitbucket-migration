#!/bin/bash

set -e

GITHUB_USER=${1}
if [ -z "${GITHUB_USER}" ]; then
  echo "Usage: ./05-push-to-github.sh [GITHUB_USER]"
  exit 1
fi

PROJECTSFILE_DEFAULT="work/projects.txt"
PROJECTSFILE_PATH="${2:-$PROJECTSFILE_DEFAULT}"
PROJECTSFILE="$(basename "${PROJECTSFILE_PATH}")"
WORK_DIR="$(dirname "${PROJECTSFILE_PATH}")"
cd "${WORK_DIR}"

gh auth status

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
        gh repo delete "${TARGET}" --confirm || true
        gh repo create "${TARGET}" --private
        for remote_name in $(git remote); do git remote remove "${remote_name}"; done
        git remote add origin git@github.com:${GITHUB_USER}/${TARGET}.git --mirror=push || true
        git push origin --mirror
        echo "gh repo delete '${TARGET}' --confirm || true" >> ../remove_from_github.sh
        cd ..
    done
    cd ..
done < ${PROJECTSFILE}
cd ..
