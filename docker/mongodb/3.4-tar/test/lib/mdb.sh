#!/bin/bash

function exe_mongo_admincmd() {
  docker run --rm ${IMAGE_NAME} mongo ${MONGODB_SUDODB} --host ${CONTAINER_IPV4} -u ${MONGODB_SUDOID} -p ${MONGODB_SUDOPW} --eval "${@}" &>/dev/null

  if [[ $? -eq 0 ]]; then
    return 0
  fi

  return 1
}
readonly -f exe_mongo_admincmd

function exe_mongo_usercmd() {
  docker run --rm ${IMAGE_NAME} mongo ${MONGODB_SUDODB} --host ${CONTAINER_IPV4} -u ${MONGODB_SUDOID} -p ${MONGODB_SUDOPW} --eval "${@}" &>/dev/null

  if [[ $? -eq 0 ]]; then
    return 0
  fi

  return 1
}
readonly -f exe_mongo_usercmd

function set_mongodb_ipv4() {
  local test_name=${1:-}; shift || return 1
  local js_command="db.getSiblingDB('test_database');"
  export CONTAINER_IPV4=$(get_container_ip ${test_name})

  for i in $(seq ${MAX_ATTEMPT}); do
    log_info "Trying connection to ${test_name}"

    if [[ $(exe_mongo_usercmd ${js_command}) -eq 0 ]]; then
      return 0
    fi

    sleep ${MAX_SLEEP}
  done

  return 1
}
readonly -f set_mongodb_ipv4
