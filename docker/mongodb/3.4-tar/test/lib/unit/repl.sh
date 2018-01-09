#!/bin/bash

function test_mongo_repl() {
  log_info "Testing replica set setup & sync"
  test_mongo_replset
}

function test_mongo_replset() {
  local test_name=replset-
  local test_netw=mongodb-replset-$$
  local test_envs=$(add2str "${REPLICASET_ENV}" "--network ${test_netw} --network-alias mongodb")

  if [[ -z "$(docker network ls -qf name=${test_netw})" ]]; then
    docker network create ${test_netw}
  fi

  run_container_entcomm ${test_name}0 ${IMAGE_NAME} run-mongod-replication ${test_envs} --hostname=${test_name}0
  docker exec $(get_container_id ${test_name}0) bash -c "while ! [ -f /tmp/initialized ]; do sleep 1; done"

  run_container_entcomm ${test_name}1 ${IMAGE_NAME} run-mongod-replication ${test_envs} --hostname=${test_name}1
  docker exec $(get_container_id ${test_name}1) bash -c "while ! [ -f /tmp/initialized ]; do sleep 1; done"

  run_container_entcomm ${test_name}2 ${IMAGE_NAME} run-mongod-replication ${test_envs} --hostname=${test_name}2
  docker exec $(get_container_id ${test_name}2) bash -c "while ! [ -f /tmp/initialized ]; do sleep 1; done"

  local host="$(docker run --rm ${REPLICASET_ENV} --network ${test_netw} ${IMAGE_NAME} bash -c '. /usr/share/container-scripts/mongodb/common.sh && echo $(replset_addr)')"

  # Storing document into replset and wait replication to finish ...
  docker run --rm ${REPLICASET_ENV} --network ${test_netw} ${IMAGE_NAME} bash -c "set -e
    . /usr/share/container-scripts/mongodb/common.sh
    . /usr/share/container-scripts/mongodb/test-functions.sh
    wait_for_mongo_up '${host}'
    wait_replicaset_members '${host}' 3
    insert_and_wait_for_replication '${host}' '{a:5, b:10}'"

  # Adding new container
  run_container_entcomm ${test_name}3 ${IMAGE_NAME} run-mongod-replication ${test_envs} --hostname=${test_name}3
  docker exec $(get_container_id ${test_name}3) bash -c "while ! [ -f /tmp/initialized ]; do sleep 1; done"

  # Storing document into replset and wait replication to finish ...
  docker run --rm ${REPLICASET_ENV} --network ${test_netw} ${IMAGE_NAME} bash -c "set -e
    . /usr/share/container-scripts/mongodb/common.sh
    . /usr/share/container-scripts/mongodb/test-functions.sh
    wait_for_mongo_up '${host}'
    wait_replicaset_members '${host}' 4
    insert_and_wait_for_replication '${host}' '{a:5, b:10}'"
}
