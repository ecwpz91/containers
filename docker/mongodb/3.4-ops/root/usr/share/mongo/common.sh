#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

export CONTAINER_PORT=27017
export MONGODB_CONFIG_FILE=${MONGODB_HOME}/conf/mms.conf
export MONGODB_PROP_FILE=${MONGODB_HOME}/conf/conf-mms.properties
export MONGODB_ADMIN_USERNAME=admin

# Configurable settings
export MONGODB_ENCRYPTED_CREDENTIALS=${MONGODB_ENCRYPTED_CREDENTIALS:-true}

# Constants used for waiting
readonly MAX_ATTEMPTS=60
readonly SLEEP_TIME=1

# wait_for_mongo_up waits until the mongo server accepts incomming connections
function wait_for_mongo_up() {
  _wait_for_mongo 1 "$@"
}

# wait_for_mongo_down waits until the mongo server is down
function wait_for_mongo_down() {
  _wait_for_mongo 0 "$@"
}

# wait_for_mongo waits until the mongo server is up/down
# $1 - 0 or 1 - to specify for what to wait (0 - down, 1 - up)
# $2 - host where to connect (localhost by default)
function _wait_for_mongo() {
  local operation=${1:-1}
  local message="up"
  if [[ ${operation} -eq 0 ]]; then
    message="down"
  fi

  local mongo_cmd="mongo admin --host ${2:-localhost} --port ${CONTAINER_PORT} "

  local i
  for i in $(seq $MAX_ATTEMPTS); do
    echo "=> ${2:-} Waiting for MongoDB daemon ${message}"
    if ([[ ${operation} -eq 1 ]] && ${mongo_cmd} --eval "quit()" &>/dev/null) || ([[ ${operation} -eq 0 ]] && ! ${mongo_cmd} --eval "quit()" &>/dev/null); then
      echo "=> MongoDB daemon is ${message}"
      return 0
    fi
    sleep ${SLEEP_TIME}
  done
  echo "=> Giving up: MongoDB daemon is not ${message}!"
  return 1
}

# Run the shell command to create a pair of encrypted credentials
# See http://bit.ly/2nQJ6Vv
function mongo_encrypt_admin() {
    if [[ -z "${MONGODB_ADMIN_PASSWORD:-}" ]]; then
      echo >&2 "=> MONGODB_ADMIN_PASSWORD is not set. Authentication can not be set up."
      exit 1
    fi

    # Encrypt admin credentials
    local result="$(echo ${MONGODB_ADMIN_PASSWORD} | credentialstool --username admin --password)"
    MONGODB_ADMIN_USERNAME="$(expr "${result}" : '.*Username:\s\(\w*\-\w*\)')"
    MONGODB_ADMIN_PASSWORD="$(expr "${result}" : '.*Password:\s\(\w*\-\w*\)')"
}
