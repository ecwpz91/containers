#!/bin/bash

# Pause/waiting
readonly MAX_ATTEMPTS=60
readonly SLEEP_TIME=1

# This is a full hostname that will be added to replica set
# (for example, "replica-2.mongodb.myproject.svc.cluster.local")
readonly MEMBER_HOST="$(hostname -f)"

# StatefulSet pods are named with a predictable name, following the pattern:
#   $(statefulset name)-$(zero-based index)
# MEMBER_ID is computed by removing the prefix matching "*-", i.e.:
#  "mongodb-0" -> "0"
#  "mongodb-1" -> "1"
#  "mongodb-2" -> "2"
readonly MEMBER_ID="${HOSTNAME##*-}"

# Account management
readonly MONGODB_ADMIN_ROLES="['dbAdminAnyDatabase', 'userAdminAnyDatabase', 'readWriteAnyDatabase', 'clusterAdmin']"
readonly MONGODB_USER_ROLES="['readWrite']"

# PATH locations
readonly MONGODB_KEYFILE_PATH=${HOME}/keyfile
readonly MONGODB_CONFIG_PATH=/etc/mongod.conf

# Exposed container port
export CONTAINER_PORT=27017

# Configuration settings
export MONGODB_QUIET=${MONGODB_QUIET:-true}

# container_addr returns the current container external IP address
function container_addr() {
  echo -n $(cat ${HOME}/.address)
}

# mongo_addr returns the IP:PORT of the currently running MongoDB instance
function mongo_addr() {
  echo -n "$(container_addr):${CONTAINER_PORT}"
}

# cache_container_addr waits till the container gets the external IP address and
# cache it to disk
function cache_container_addr() {
  echo -n "=> Waiting for container IP address ..."
  local i
  for i in $(seq "$MAX_ATTEMPTS"); do
    if ip -oneline -4 addr show up scope global | grep -Eo '[0-9]{,3}(\.[0-9]{,3}){3}' > "${HOME}"/.address; then
      echo " $(mongo_addr)"
      return 0
    fi
    sleep $SLEEP_TIME
  done
  echo >&2 "Failed to get Docker container IP address." && exit 1
}

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

  local mongo_cmd="mongo admin --host ${2:-localhost} --port ${CONTAINER_PORT}"

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

# Wait for document that describes the role of the mongod instance
#
# Global variables:
# - SLEEP_TIME
function wait_for_replset() {
  local js_command="while (!rs.isMaster().ismaster && !rs.isMaster().secondary) { sleep({${SLEEP_TIME}*100}); }"

  info "Waiting for PRIMARY/SECONDARY status ..."
  mongo --eval ${js_command} --quiet
}

# endpoints returns list of IP addresses with other instances of MongoDB
# To get list of endpoints, you need to have headless Service named 'mongodb'.
# [NOTE] This won't work with standalone Docker container.
function endpoints() {
  service_name=${MONGODB_SERVICE_NAME:-mongodb}
  dig ${service_name} A +search +short 2>/dev/null
}

# build_mongo_config builds the MongoDB replicaSet config used for the cluster
# initialization.
# Takes a list of space-separated member IPs as the first argument.
function build_mongo_config() {
  local current_endpoints
  current_endpoints="$1"
  local members
  members="{ _id: 0, host: \"$(mongo_addr)\"},"
  local member_id
  member_id=1
  local container_addr
  container_addr="$(container_addr)"
  local node
  for node in ${current_endpoints}; do
    if [[ "$node" != "$container_addr" ]]; then
      members+="{ _id: ${member_id}, host: \"${node}:${CONTAINER_PORT}\"},"
      let member_id++
    fi
  done
  echo -n "var config={ _id: \"${MONGODB_REPLICA_NAME}\", members: [ ${members%,} ] }"
}

# mongo_initiate initiates the replica set.
# Takes a list of space-separated member IPs as the first argument.
function mongo_initiate() {
  local mongo_wait
  mongo_wait="while (rs.status().startupStatus || (rs.status().hasOwnProperty(\"myState\") && rs.status().myState != 1)) { printjson( rs.status() ); sleep(1000); }; printjson( rs.status() );"
  config=$(build_mongo_config "$1")
  echo "=> Initiating MongoDB replica using: ${config}"
  mongo admin --eval "${config};rs.initiate(config);${mongo_wait}"
}

# Gets the IP's the current replSet.
#
# Global variables:
# - MONGODB_SERVICE_NAME
function replset_addr() {
  local current_endpoints=$(endpoints)

  if [[ -z "${current_endpoints}" ]]; then
    info "Cannot get address of replica set: no nodes are listed in service!"
    info "CAUSE: DNS lookup for '${MONGODB_SERVICE_NAME:-mongodb}' returned no results."
    return 1
  fi

  echo -n "${current_endpoints//[[:space:]]/,}"
}

# Gets the URI format for defining connections.
#
# Arguments:
# - $1: dbase (default admin)
#
# Global variables:
# - MONGODB_REPLICA_NAME
function replset_conn_uri() {
  local dbase=${2:-admin}
  local hosts=$(replset_addr)

  if [[ -z "${hosts}" ]]; then
    info "ERROR: Cannot determine the IP address of the replica set primary"
    info "CAUSE: NULL host, exiting (no error) to allow callers to continue"
    return
  fi

  echo -n "mongodb://${hosts}/${dbase}?replicaSet=${MONGODB_REPLICA_NAME}"
}

# Gets the URI format for defining connections.
#
# Arguments:
# - $1: host address[:port]
#
# Global variables:
# - MONGODB_REPLICA_NAME
function replset_admincmd() {
  mongo --host "$(replset_conn_uri)" -u admin -p "${MONGODB_ADMIN_PASSWORD}" --eval "${@}"
}

# mongo_create_admin creates the MongoDB admin user with password: MONGODB_ADMIN_PASSWORD
# $1 - login parameters for mongo (optional)
# $2 - host where to connect (localhost by default)
function mongo_create_admin() {
  if [[ -z "${MONGODB_ADMIN_PASSWORD:-}" ]]; then
    echo >&2 "=> MONGODB_ADMIN_PASSWORD is not set. Authentication can not be set up."
    exit 1
  fi

  # Set admin password
  local js_command="db.createUser({user: 'admin', pwd: '${MONGODB_ADMIN_PASSWORD}', roles: ${MONGODB_ADMIN_ROLES}});"
  if ! mongo admin ${1:-} --host ${2:-"localhost"} --eval "${js_command}"; then
    echo >&2 "=> Failed to create MongoDB admin user."
    exit 1
  fi
}

# mongo_create_user creates the MongoDB database user: MONGODB_USER,
# with password: MONGDOB_PASSWORD, inside database: MONGODB_DATABASE
# $1 - login parameters for mongo (optional)
# $2 - host where to connect (localhost by default)
function mongo_create_user() {
  # Ensure input variables exists
  if [[ -z "${MONGODB_USER:-}" ]]; then
    echo >&2 "=> MONGODB_USER is not set. Failed to create MongoDB user"
    exit 1
  fi
  if [[ -z "${MONGODB_PASSWORD:-}" ]]; then
    echo >&2 "=> MONGODB_PASSWORD is not set. Failed to create MongoDB user: ${MONGODB_USER}"
    exit 1
  fi
  if [[ -z "${MONGODB_DATABASE:-}" ]]; then
    echo >&2 "=> MONGODB_DATABASE is not set. Failed to create MongoDB user: ${MONGODB_USER}"
    exit 1
  fi

  # Create database user
  local js_command="db.getSiblingDB('${MONGODB_DATABASE}').createUser({user: '${MONGODB_USER}', pwd: '${MONGODB_PASSWORD}', roles: ${MONGODB_USER_ROLES}});"
  if ! mongo admin ${1:-} --host ${2:-"localhost"} --eval "${js_command}"; then
    echo >&2 "=> Failed to create MongoDB user: ${MONGODB_USER}"
    exit 1
  fi
}

# mongo_reset_user sets the MongoDB MONGODB_USER's password to match MONGODB_PASSWORD
function mongo_reset_user() {
  if [[ -n "${MONGODB_USER:-}" && -n "${MONGODB_PASSWORD:-}" && -n "${MONGODB_DATABASE:-}" ]]; then
    local js_command="db.changeUserPassword('${MONGODB_USER}', '${MONGODB_PASSWORD}')"
    if ! mongo ${MONGODB_DATABASE} --eval "${js_command}"; then
      echo >&2 "=> Failed to reset password of MongoDB user: ${MONGODB_USER}"
      exit 1
    fi
  fi
}

# mongo_reset_admin sets the MongoDB admin password to match MONGODB_ADMIN_PASSWORD
function mongo_reset_admin() {
  if [[ -n "${MONGODB_ADMIN_PASSWORD:-}" ]]; then
    local js_command="db.changeUserPassword('admin', '${MONGODB_ADMIN_PASSWORD}')"
    if ! mongo admin --eval "${js_command}"; then
      echo >&2 "=> Failed to reset password of MongoDB user: ${MONGODB_USER}"
      exit 1
    fi
  fi
}

# setup_keyfile fixes the bug in mounting the Kubernetes 'Secret' volume that
# mounts the secret files with 'too open' permissions.
# add --fork --logpath argument to mongo_common_args
function setup_keyfile() {
  # If user specify keyFile in config file do not use generated keyFile
  if grep -q "^\s*keyFile" ${MONGODB_CONFIG_PATH}; then
    exit 0
  fi
  if [[ -z "${MONGODB_KEYFILE_VALUE-}" ]]; then
    echo >&2 "ERROR: You have to provide the 'keyfile' value in MONGODB_KEYFILE_VALUE"
    exit 1
  fi
  local keyfile_dir
  keyfile_dir="$(dirname "$MONGODB_KEYFILE_PATH")"
  if [[ ! -w "$keyfile_dir" ]]; then
    echo >&2 "ERROR: Couldn't create ${MONGODB_KEYFILE_PATH}"
    echo >&2 "CAUSE: current user doesn't have permissions for writing to ${keyfile_dir} directory"
    echo >&2 "DETAILS: current user id = $(id -u), user groups: $(id -G)"
    echo >&2 "DETAILS: directory permissions: $(stat -c '%A owned by %u:%g' "${keyfile_dir}")"
    exit 1
  fi
  echo ${MONGODB_KEYFILE_VALUE} > ${MONGODB_KEYFILE_PATH}
  chmod 0600 ${MONGODB_KEYFILE_PATH}
  mongo_common_args+=" --keyFile ${MONGODB_KEYFILE_PATH}"
}


# setup_default_datadir checks permissions of mounded directory into default
# data directory APP_DAT_PATH
function setup_default_datadir() {
  if [ ! -w "$APP_DAT_PATH" ]; then
    echo >&2 "ERROR: Couldn't write into ${APP_DAT_PATH}"
    echo >&2 "CAUSE: current user doesn't have permissions for writing to ${APP_DAT_PATH} directory"
    echo >&2 "DETAILS: current user id = $(id -u), user groups: $(id -G)"
    echo >&2 "DETAILS: directory permissions: $(stat -c '%A owned by %u:%g, SELinux: %C' "${APP_DAT_PATH}")"
    exit 1
  fi
}

# setup_wiredtiger_cache checks amount of available RAM (it has to use cgroups in container)
# and if there are any memory restrictions set storage.wiredTiger.engineConfig.cacheSizeGB
# in MONGODB_CONFIG_PATH to upstream default size
# it is intended to update mongodb.conf.template, with custom config file it might create conflict
function setup_wiredtiger_cache() {
  local config_file
  config_file=${1:-$MONGODB_CONFIG_PATH}

  declare $(cgroup-limits)
  if [[ ! -v MEMORY_LIMIT_IN_BYTES || "${NO_MEMORY_LIMIT:-}" == "true" ]]; then
    return 0;
  fi

  cache_size=$(python -c "min=1; limit=int(($MEMORY_LIMIT_IN_BYTES / pow(2,30) - 1) * 0.6); print( min if limit < min else limit)")
  echo "storage.wiredTiger.engineConfig.cacheSizeGB: ${cache_size}" >> ${config_file}

  info "wiredTiger cacheSizeGB set to ${cache_size}"
}

# check_env_vars checks environmental variables
# if variables to create non-admin user are provided, sets CREATE_USER=1
# if REPLICATION variable is set, checks also replication variables
function check_env_vars() {
  local readonly database_regex='^[^/\. "$]*$'

  [[ -v MONGODB_ADMIN_PASSWORD ]] || usage "MONGODB_ADMIN_PASSWORD has to be set."

  if [[ -v MONGODB_USER || -v MONGODB_PASSWORD || -v MONGODB_DATABASE ]]; then
    [[ -v MONGODB_USER && -v MONGODB_PASSWORD && -v MONGODB_DATABASE ]] || usage "You have to set all or none of variables: MONGODB_USER, MONGODB_PASSWORD, MONGODB_DATABASE"

    [[ "${MONGODB_DATABASE}" =~ $database_regex ]] || usage "Database name must match regex: $database_regex"
    [ ${#MONGODB_DATABASE} -le 63 ] || usage "Database name too long (maximum 63 characters)"

    export CREATE_USER=1
  fi

  if [[ -v REPLICATION ]]; then
    [[ -v MONGODB_KEYFILE_VALUE && -v MONGODB_REPLICA_NAME ]] || usage "MONGODB_KEYFILE_VALUE and MONGODB_REPLICA_NAME have to be set"
  fi
}

# usage prints info about required enviromental variables
# if $1 is passed, prints error message containing $1
# if REPLICATION variable is set, prints also info about replication variables
function usage() {
  if [ $# == 1 ]; then
    echo >&2 "error: $1"
  fi

  echo "
  You must specify the following environment variables:
  MONGODB_ADMIN_PASSWORD
  Optionally you can provide settings for a user with 'readWrite' role:
  (Note you MUST specify all three of these settings)
  MONGODB_USER
  MONGODB_PASSWORD
  MONGODB_DATABASE
  Optional settings:
  MONGODB_QUIET (default: true)"

  if [[ -v REPLICATION ]]; then
    echo "
    For replication you must also specify the following environment variables:
    MONGODB_KEYFILE_VALUE
    MONGODB_REPLICA_NAME
    Optional settings:
    MONGODB_SERVICE_NAME (default: mongodb)
    "
  fi
  echo "
  For more information see /usr/share/container-scripts/mongodb/README.md
  within the container or visit https://github.com/sclorgk/mongodb-container/."

  exit 1
}

# info prints a message prefixed by date and time.
function info() {
  printf "=> [%s] %s\n" "$(date +'%a %b %d %T')" "$*"
}
