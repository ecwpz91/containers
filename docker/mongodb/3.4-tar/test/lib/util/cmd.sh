#!/bin/bash

# cmd_pass (boolean); true input returns 0 (true)
function cmd_pass() {
  local inputparam=${1:-""}

  # Check for empty string
  if [[ -z "${inputparam}" ]]; then
    return 0
  fi

  local inputlower=$(echo -n "${inputparam,,}")
  local inputascii=$(printf '%d\n' "'${inputlower}'")
  local true_ascii=$(printf '%d\n' "'true'")
  local zero_ascii=$(printf '%d\n' "'0'")

  case "${inputascii}" in
    "${true_ascii}" ) return 0
    ;;
    "${zero_ascii}" ) return 0
    ;;
    "" ) return 0
    ;;
    *) return 1
    ;;
  esac
}
readonly -f cmd_pass

# cmd_fail (boolean); false input returns 0 (true)
function cmd_fail() {
  local inputparam=${1:-""}

  # Check for empty string
  if [[ -z "${inputparam}" ]]; then
    return 1
  fi

  local inputlower=$(echo -n "${inputparam,,}")
  local inputascii=$(printf '%d\n' "'${inputlower}'")
  local false_ascii=$(printf '%d\n' "'false'")
  local one_ascii=$(printf '%d\n' "'1'")

  case "${inputascii}" in
    "${false_ascii}" ) return 1
    ;;
    "${one_ascii}" ) return 1
    ;;
    "" ) return 1
    ;;
    *) return 0
    ;;
  esac
}
readonly -f cmd_fail
