#!/bin/bash

function test_mongo_crud() {
  log_info "Test CRUD commands with user private group"
  test_mongo_crud_upg
  log_info "Test CRUD commands with random user id"
  test_mongo_crud_uid
}
readonly -f test_mongo_crud

function test_mongo_crud_upg() {
  local test_name=${FUNCNAME[0]}

  run_container ${test_name} ${IMAGE_NAME} ${STANDALONE_ENV}
  set_mongodb_ipv4 ${test_name}
  admin_crud_cmds
  user_crud_cmds
  stop_container ${test_name}
}
readonly -f test_mongo_crud_upg

function test_mongo_crud_uid() {
  local test_name=${FUNCNAME[0]}
  local test_envs=$(add2str "${STANDALONE_ENV}" "-u 12345")

  run_container ${test_name} ${IMAGE_NAME} ${test_envs}
  set_mongodb_ipv4 ${test_name}
  admin_crud_cmds
  user_crud_cmds
  stop_container ${test_name}
}
readonly -f test_mongo_crud_uid

function admin_crud_cmds() {
  log_info "Testing admin CURD commands"
  exe_mongo_admincmd "db=db.getSiblingDB('${MONGODB_USERDB}');db.dropUser('${MONGODB_USERID}');"
  exe_mongo_admincmd "db=db.getSiblingDB('${MONGODB_USERDB}');db.createUser({user:'${MONGODB_USERID}',pwd:'${MONGODB_USERPW}',roles:['readWrite','userAdmin','dbAdmin']});"
  exe_mongo_admincmd "db=db.getSiblingDB('${MONGODB_USERDB}');db.testData.insert({x:0});"
}
readonly -f admin_crud_cmds

function user_crud_cmds() {
  log_info "Testing user CURD commands"
  exe_mongo_usercmd "db.createUser({user:'test_user2',pwd:'test_password2',roles:['readWrite']});"
  exe_mongo_usercmd "db.testData.insert({ y : 1 });"
  exe_mongo_usercmd "db.testData.insert({ z : 2 });"
  exe_mongo_usercmd "db.testData.find().forEach(printjson);"
  exe_mongo_usercmd "db.testData.count();"
  exe_mongo_usercmd "db.testData.drop();"
  exe_mongo_usercmd "db.dropDatabase();"
}
readonly -f user_crud_cmds
