#!/bin/bash

function test_mongo_envs() {
  log_info "Testing wrong user variables usage"
  test_envs_fail_user_pass
  test_envs_fail_db_pass
  test_envs_fail_db_user
  test_envs_fail_user_db_pass

  log_info "Testing good user variables usage"
  test_envs_pass_admin || [ $? -eq 1 ]
  get_test_envs_result ${STANDALONE_ENV} || [ $? -eq 1 ]
}

function get_test_envs_result() {
  local envs=${1:-}; shift
  local stat=$(get_run_container_timeout_status ${IMAGE_NAME} 10 9 ${envs})

  if [ ${stat} -gt ${MAX_TIMEOUT} ]; then
    return 1
  fi

  return 0
}

# -e MONGODB_USER=user -e MONGODB_PASSWORD=pass
function test_envs_fail_user_pass() {
  local test_envs
  test_envs=$(str2rem "${STANDALONE_ENV}" "${DEF_USERDB_ENV}")
  test_envs=$(str2rem "${test_envs}" "${DEF_SUDOPW_ENV}")

  log_info "${FUNCNAME[0]}"
  get_test_envs_result "${test_envs}"
}

# -e MONGODB_DATABASE=db -e MONGODB_PASSWORD=pass
function test_envs_fail_db_pass() {
  local test_envs
  test_envs=$(str2rem "${STANDALONE_ENV}" "${DEF_USERID_ENV}")
  test_envs=$(str2rem "${test_envs}" "${DEF_SUDOPW_ENV}")

  log_info "${FUNCNAME[0]}"
  get_test_envs_result "${test_envs}"
}

# -e MONGODB_DATABASE=db -e MONGODB_USER=user
function test_envs_fail_db_user() {
  local test_envs
  test_envs=$(str2rem "${STANDALONE_ENV}" "${DEF_USERPW_ENV}")
  test_envs=$(str2rem "${test_envs}" "${DEF_SUDOPW_ENV}")

  log_info "${FUNCNAME[0]}"
  get_test_envs_result "${test_envs}"
}

# -e MONGODB_USER=user -e MONGODB_DATABASE=db -e MONGODB_PASSWORD=pass
function test_envs_fail_user_db_pass() {
  local test_envs
  test_envs=$(str2rem "${STANDALONE_ENV}" "${DEF_SUDOPW_ENV}")

  log_info "${FUNCNAME[0]}"
  get_test_envs_result "${test_envs}"
}

# -e MONGODB_ADMIN_PASSWORD=Pass -e MONGODB_USER=user
function test_envs_fail_user_admin() {
  local test_envs
  test_envs=$(str2rem "${STANDALONE_ENV}" "${DEF_USERDB_ENV}")
  test_envs=$(str2rem "${test_envs}" "${DEF_USERPW_ENV}")

  log_info "${FUNCNAME[0]}"
  get_test_envs_result "${test_envs}"
}

# -e MONGODB_ADMIN_PASSWORD=Pass -e MONGODB_PASSWORD=pass
function test_envs_fail_pass_admin() {
  local test_envs
  test_envs=$(str2rem "${STANDALONE_ENV}" "${DEF_USERID_ENV}")
  test_envs=$(str2rem "${test_envs}" "${DEF_USERDB_ENV}")

  log_info "${FUNCNAME[0]}"
  get_test_envs_result "${test_envs}"
}

# -e MONGODB_ADMIN_PASSWORD=Pass -e MONGODB_DATABASE=db
function test_envs_fail_pass_db() {
  local test_envs
  test_envs=$(str2rem "${STANDALONE_ENV}" "${DEF_USERID_ENV}")
  test_envs=$(str2rem "${test_envs}" "${DEF_USERPW_ENV}")

  log_info "${FUNCNAME[0]}"
  get_test_envs_result "${test_envs}"
}

# -e MONGODB_ADMIN_PASSWORD=Pass
function test_envs_pass_admin() {
  local test_envs
  test_envs=$(str2rem "${STANDALONE_ENV}" "${DEF_USERDB_ENV}")
  test_envs=$(str2rem "${test_envs}" "${DEF_USERID_ENV}")
  test_envs=$(str2rem "${test_envs}" "${DEF_USERPW_ENV}")

  log_info "${FUNCNAME[0]}"
  get_test_envs_result "${test_envs}"
}
