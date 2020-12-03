#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

usage() {
  echo "Usage: $0 URL COMMIT DEST" 1>&2
  exit 1
}

if [ $# -ne 3 ]; then
  usage
fi


#------------------------------------------------
url=$1
commit=$2
dest=$3

if [ -d "${dest}" ]; then
  # The destination directory already exists, assume it contains the correct
  # repository
  cd "${dest}" 
else
  # Clone the repository to the given destination
  git clone "${url}" "${dest}"
  cd "${dest}"
fi

git checkout "${commit}"
