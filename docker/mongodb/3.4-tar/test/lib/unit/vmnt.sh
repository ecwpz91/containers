#!/bin/bash

function test_mongo_vmnt() {
  log_info "Test mount conf file"
  test_mongo_mount_conf
}

function test_mongo_mount_conf() {
  local test_name=${FUNCNAME[0]}
  local test_vmnt=${OS_VOLUME_DIR}/${test_name}
  local test_conf=${test_vmnt}/mongod.conf
  local test_envs=$(add2str "${STANDALONE_ENV}" "-v ${test_vmnt}:${MONGODB_DATADIR_PATH}:Z -v ${test_conf}:${MONGODB_CONFIG_FILE}:Z")

  log_info "Make volume mount directory"
  [ -d ${test_vmnt} ] || mkdir -p ${test_vmnt}
  chmod a+rwx ${test_vmnt}

  log_info "Make conf file"
  echo "dbpath=${MONGODB_DATADIR_PATH}
  unixSocketPrefix = /var/lib/mongodb" > $test_conf
  chmod a+r ${test_conf}

  run_container ${test_name} ${IMAGE_NAME} ${test_envs}
  set_mongodb_ipv4 ${test_name}

  log_info "Testing config file works"
  if docker exec $(get_container_id ${test_name}) bash -c "test -S /var/lib/mongodb/mongodb-27017.sock"; then
    echo $?
  fi

  log_info "Perform cleanup"
  docker exec $(get_container_id ${test_name}) bash -c "rm -rf ${MONGODB_DATADIR_PATH}/*"
  stop_container ${test_name}
}
