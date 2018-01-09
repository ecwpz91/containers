#!/bin/bash

function add2str() {
  local str=${1:-}; shift

  echo -n "${str}" ${@}""
}
readonly -f add2str

function str2rem() {
  local str=${1:-}; shift

  echo -n "${str}" | sed -e "s|${@}||"
}
readonly -f str2rem

function trim() {
  echo -n "${@}" | sed -e "s|[\s]+$||"
}
readonly -f trim
