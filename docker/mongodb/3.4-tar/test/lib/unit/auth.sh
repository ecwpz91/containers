#!/bin/bash

function test_mongo_auth() {
  log_info "Test admin/user password reset"
  test_mongo_password_reset
}

function test_mongo_password_reset() {
  local test_name=${FUNCNAME[0]}
  local test_vmnt=${OS_VOLUME_DIR}/${test_name}
  local test_envs=$(add2str "${STANDALONE_ENV}" "-v ${test_vmnt}:${MONGODB_DATADIR_PATH}:Z")

  log_info "Make volume mount directory"
  [ -d ${test_vmnt} ] || mkdir -p ${test_vmnt}
  chmod a+rwx ${test_vmnt}

  run_container ${test_name} ${IMAGE_NAME} ${test_envs}
  set_mongodb_ipv4 ${test_name}

  log_info "Testing login"
  test_mongo_admin_password
  test_mongo_user_password
  docker stop $(get_container_id ${test_name})

  log_info "Changing passwords"
  MONGODB_SUDOPW="new_${MONGODB_SUDOPW}"
  MONGODB_USERPW="new_${MONGODB_USERPW}"
  test_envs="${DEF_USERDB_ENV} ${DEF_USERID_ENV} -e MONGODB_PASSWORD=${MONGODB_USERPW} -e MONGODB_ADMIN_PASSWORD=${MONGODB_SUDOPW} -v ${test_vmnt}:${MONGODB_DATADIR_PATH}:Z"

  log_info "Testing login with new passwords"
  run_container ${test_name}_new ${IMAGE_NAME} ${test_envs}
  set_mongodb_ipv4 ${test_name}_new
  test_mongo_admin_password
  test_mongo_user_password

  log_info "Perform cleanup"
  docker exec $(get_container_id ${test_name}_new) bash -c "rm -rf ${MONGODB_DATADIR_PATH}/*"
  stop_container ${test_name}
  stop_container ${test_name}_new
}

function test_mongo_admin_password() {
  local js_command="db.version();"

  if $(exe_mongo_admincmd ${js_command}); then
    return 0
  fi

  return 1
}

function test_mongo_user_password() {
  local js_command="db.version();"

  if $(exe_mongo_usercmd ${js_command}); then
    return 0
  fi

  return 1
}
