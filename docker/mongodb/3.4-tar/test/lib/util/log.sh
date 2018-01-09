#!/bin/bash

readonly OS_FAIL=0
readonly OS_PASS=1
readonly OS_INFO=2

function log_pass() {
  log_print ${OS_PASS} "${1:-${FUNCNAME[0]}}"
}
readonly -f log_pass

function log_fail() {
  log_print ${OS_FAIL} "${1:-${FUNCNAME[0]}}"
}
readonly -f log_fail

function log_info() {
  log_print ${OS_INFO} "${1:-${FUNCNAME[0]}}"
}
readonly -f log_info

function log_print(){
  local opts=${1:-}; shift || return 1
  local tstp=$(date +'%a %b %d %T')

  case ${opts} in
    ${OS_PASS} ) echo "${tstp} [PASS] $@"
    ;;
    ${OS_INFO} ) echo "${tstp} [INFO] $@"
    ;;
    *) echo "${tstp} [FAIL] $@"
    ;;
  esac
}
readonly -f log_print
