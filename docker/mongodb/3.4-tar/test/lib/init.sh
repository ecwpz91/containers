#!/bin/bash

# This script is the entrypoint for Bash scripts to import all of the support libraries.

set -o errexit
set -o nounset
set -o pipefail

function absolute_path() {
	local relative_path="$1"
	local absolute_path
	pushd "${relative_path}" >/dev/null
	relative_path="$( pwd )"
	if [[ -h "${relative_path}" ]]; then
		absolute_path="$( readlink "${relative_path}" )"
	else
		absolute_path="${relative_path}"
	fi
	popd >/dev/null

	echo "${absolute_path}"
}
readonly -f absolute_path

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
SOURCE="$(readlink "$SOURCE")"
[[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
DIR_ABSOLUTE_PATH="$(absolute_path "$DIR/../..")"

export OS_ROOT="${OS_ROOT:-"${DIR_ABSOLUTE_PATH}"}"

OS_TEST="${OS_TEST:-"${OS_ROOT}/test"}"
OS_TEST_LIB="${OS_TEST_LIB:-"${OS_TEST}/lib"}"

# Concatenate library files
library_files=( $( find "${OS_TEST_LIB}" -type f -name '*.sh' -not -path "*${OS_TEST_LIB}/init.sh" ) )

# Load libraries into current shell
for library_file in "${library_files[@]}"; do
	source "${library_file}"
done

unset library_files library_file OS_TEST OS_TEST_LIB
