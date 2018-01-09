#!/bin/bash

# Initializes the replica set configuration.
#
# Arguments:
# - $1: host address[:port]
#
# Global variables:
# - SLEEP_TIME
# - MONGODB_REPLICA_NAME
# - MONGODB_ADMIN_PASSWORD
function initiate() {
  local host="$1"
  local config="{_id: '${MONGODB_REPLICA_NAME}', members: [{_id: 0, host: '${host}'}]}"
  local js_command="quit(rs.initiate(${config}).ok ? 0 : 1)"

  info "Initiating MongoDB replica using: ${config}"
  mongo --eval ${js_command} --quiet

  wait_for_replset

  info "Creating MongoDB users ..."
  mongo_create_admin
  [[ -v CREATE_USER ]] && mongo_create_user "-u admin -p ${MONGODB_ADMIN_PASSWORD}"

  info "Successfully initialized replica set"
}

# Adds a host to the replica set configuration, e.g. rs.add('$(mongo_addr)').
#
# Arguments:
# - $1: host address[:port]
#
# Global variables:
# - SLEEP_TIME
# - MONGODB_REPLICA_NAME
# - MONGODB_ADMIN_PASSWORD
function replset_add_member() {
  local host="$1"
  local js_command="while (!rs.add('${host}').ok) { sleep({${SLEEP_TIME}*100}); }"

  info "Adding ${host} to replica set ..."
  if ! replset_admincmd ${js_command} --quiet; then
    info "ERROR: couldn't add host to replica set!"
    return 1
  fi

  wait_for_replset

  info "Successfully joined replica set"
}

# rs_remove_member removes the current MongoDB from the cluster
function rs_remove_member() {
  local mongo_addr=$(mongo_addr)
  local js_command="rs.remove('${mongo_addr}');"

  echo "=> Removing ${mongo_addr} from replica set ..."
  replset_admincmd ${js_command}
}

# Initialize the replica set or add member in the background.
#
# Global variables:
# - MONGODB_REPLICA_NAME
# - MEMBER_ID
# - MEMBER_HOST
function replicaset() {
  local js_command="db.isMaster().setName"

  wait_for_mongo_up &>/dev/null

  if [[ "$(mongo --eval "$js_command" --quiet)" == "${MONGODB_REPLICA_NAME}" ]]; then
    info "Replica set '${MONGODB_REPLICA_NAME}' already exists, skipping initialization"
    >/tmp/initialized
    exit 0
  fi

  # Initialize replica set only if we're the first member
  if [ "${MEMBER_ID}" = '0' ]; then
    initiate "${MEMBER_HOST}"
  else
    replset_add_member "${MEMBER_HOST}"
  fi

  >/tmp/initialized
}
