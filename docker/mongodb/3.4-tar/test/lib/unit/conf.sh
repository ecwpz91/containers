#!/bin/bash

function test_mongo_conf() {
  log_info "Test quiet configuration setting"
  test_conf_pass_quiet
  log_info "Test WiredTiger storage engine cache"
  test_conf_wt_cache
}

function test_conf_pass_quiet() {
  local test_name=${FUNCNAME[0]}
  local test_envs=$(add2str "${STANDALONE_ENV}" "${DEF_QUIETS_ENV}")
  local config_part="quiet: true"

  run_container ${test_name} ${IMAGE_NAME} ${test_envs}
  set_mongodb_ipv4 ${test_name}

  # If nothing is found, grep returns 1 and test fails.
  docker exec $(get_container_id ${test_name}) bash -c "cat ${MONGODB_CONFIG_FILE}" | grep -q "${config_part}"

  stop_container ${test_name}
}

function test_conf_wt_cache() {
  local test_name=${FUNCNAME[0]}
  local test_envs=$(add2str "${STANDALONE_ENV}" "-m 200M")

  run_container ${test_name}_200M ${IMAGE_NAME} ${test_envs}
  set_mongodb_ipv4 ${test_name}_200M

  # Minimum is 1G
  exe_mongo_admincmd "if (db.serverStatus()['wiredTiger']['cache']['maximum bytes configured'] == Math.pow(2,30)){quit(0)}; quit(1)"

  stop_container ${test_name}_200M

  test_envs=$(add2str "${STANDALONE_ENV}" "-m 6G")

  run_container ${test_name}_6G ${IMAGE_NAME} ${test_envs}
  set_mongodb_ipv4 ${test_name}_6G

  # If greater that 1G, use 60% of (RAM - 1G)
  exe_mongo_admincmd "if (db.serverStatus()['wiredTiger']['cache']['maximum bytes configured'] == 3*Math.pow(2,30)){quit(0)}; quit(1)"

  stop_container ${test_name}_6G
}
