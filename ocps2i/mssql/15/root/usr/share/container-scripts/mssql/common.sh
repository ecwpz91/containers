#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck source=/dev/null
source ${CONTAINER_SCRIPTS_PATH:-}/environment

#----------------------------------------------------
# Verification
#----------------------------------------------------

# @public  Checks environmental variables.
#
# @value  SA_PASSWORD
# @value  ACCEPT_EULA
#
# 05/2021 Marked function as readonly.
function check_env_vars() {
  local database_regex='^[^/\. "$]*$'

  [[ -v SA_PASSWORD ]] || usage "SA_PASSWORD has to be set."

  [[ -v ACCEPT_EULA ]] || usage "ACCEPT_EULA has to be set."
}
readonly -f check_env_vars

# @public  Checks permissions of database volume.
#
# @value  MSSQL_DATADIR
#
# 05/2017 Renamed function from `setup_default_datadir` to `check_data_dir` to
#         improve execution order & legibility.
# 05/2017 Marked function as readonly.
function check_data_dir() {
  if [ ! -w "${MSSQL_DATADIR:-}" ]; then
    log_fail "Couldn't write into ${MSSQL_DATADIR:-}"
    log_fail "Current user id = $(id -u), and user groups: $(id -G) don't have permissions"
    log_fail "Directory permissions: $(stat -c '%A owned by %u:%g, SELinux = %C' ${MSSQL_DATADIR:-})"
    exit 1
  fi
}
readonly -f check_data_dir

#----------------------------------------------------
# Synchronization
#----------------------------------------------------

# @public Waits until the sqlservr daemon connection is up.
#
# @param  $@ host where to connect
#
# 05/2017 Marked function as readonly.
function wait_for_mssql_up() {
  _wait_for_mssql 1 "$@"
}
readonly -f wait_for_mssql_up

# @public Waits until the sqlservr daemon connection is down.
#
# @param  $@ host where to connect
#
# 05/2017 Marked function as readonly.
function wait_for_mssql_down() {
  _wait_for_mssql 0 "$@"
}
readonly -f wait_for_mssql_down

# @private Helper method that waits until the sqlsrv daemon is up/down.
#
# @param  $1 desired connection state (default down)
# @param  $2 host where to connect (default localhost)
#
# 05/2017 Marked function as readonly.
function _wait_for_mssql() {
  local hold=${1:-1}
  local host=${2:-localhost}
  local comm="SELECT @@VERSION;"
  local stat

  [[ ${hold} -eq 0 ]] && stat="down" || stat="up"

  for i in $(seq $MAX_ATTEMPTS); do
    log_info "Waiting for ${host} connection"

    if ([[ ${hold} -eq 1 ]] && $SQLCMD -S "${host}" -U "${SA_USER:-}" -P "${SA_PASSWORD:-}" -d master -Q "${comm}" &>/dev/null) || \
       ([[ ${hold} -eq 0 ]] && ! $SQLCMD -S "${host}" -U "${SA_USER:-}" -P "${SA_PASSWORD:-}" -d master -Q "${comm}" &>/dev/null); then
      log_pass "Connection is ${stat}"
      return 0
    fi

    sleep $(( i++ ))
  done

  log_fail "Connection is NOT ${stat}"
  return 1
}
readonly -f _wait_for_mssql

# @public Cleanly and safely terminates the Microsoft SQL Server daemon.
#
# 05/2021 Marked function as readonly.
function cleanup() {
  log_info "Shutting down $(hostfqdn)"
  pkill -INT $SQLSERVR || :
  wait_for_mssql_down "localhost"
  exit 0
}
readonly -f cleanup

# @public Make sure environment variables don't propagate.
#
# @value  SA_USER
# @value  SA_PASSWORD
#
# 06/2017 Initial revision.
function unset_env_vars() {
	unset SA_USER SA_PASSWORD
}

#----------------------------------------------------
# Networking
#----------------------------------------------------

# @public Returns standard format of the Microsoft SQL Server 2019 connection URI used to connect
#         to a Microsoft SQL Server 2019 database server. It identifies either a hostname, IP
#         address, or UNIX domain socket.
#
# @param  -h <hostname>
# @param  -u <username>
# @param  -p <password>
# @param  -d <database>
#
# 05/2017 Initial revision.
# 05/2017 Added new arguments optarg.
function endpoint() {
  endpoint_usage() { log_info "usage: ${FUNCNAME[0]} -h <hostname> -u <username> -p <password> -d <database>]" 1>&2; exit 1; }

  local OPTIND opt host user pass creds data uri

  while getopts ":h:u:p:d:" opt; do
    case ${opt} in
      h  ) host=$OPTARG ;;
      u  ) user=$OPTARG ;;
      p  ) pass=$OPTARG ;;
      d  ) data=$OPTARG ;;
      \? ) endpoint_usage ;;
    esac
  done

  shift $((${OPTIND} - 1))

  if [[ -n "${user:-}" ]] && [[ -n "${pass:-}" ]]; then
    creds="${user}:${pass}@"
  elif [[ -n "${user:-}" ]] && [[ -z "${pass:-}" ]]; then
    log_fail "Username provided, but password is not set."
    endpoint_usage
  elif [[ -z "${user:-}" ]] && [[ -n "${pass:-}" ]]; then
    log_fail "Password provided, but username is not set."
    endpoint_usage
  fi

  if [[ -z "${host:-}" ]]; then
    host=$(hostfqdn)
  fi

  [[ -n "${data:-}" ]] && uri="$(host2ipa ${host:-})/${data:-}" || uri="$(host2ipa ${host:-})"

  echo "${creds:-}${uri:-}"
}
readonly -f endpoint

# @public Returns fully qualified domain name (FQDN) of the Microsoft SQL Server 2019 daemon.
#
# 05/2017 Use hostname command, rather than cached IP address
# 05/2017 Marked function as readonly.
function hostfqdn() {
  [[ -z "$(type -P hostname &>/dev/null)" ]] \
  && [[ -n "$(hostname -f)" ]] \
  && echo "$(hostname -f)" || echo "localhost"
}
readonly -f hostfqdn


# @public Identifies a server IP address to connect to.
#
# @param  $1 host where to connect
# @return IP address
#
# 05/2017 Initial revision.
function host2ipa() {
  local host=${1:-}
  local addr

  if type -P dig &>/dev/null; then
    addr=$(dig ${host} A +search +short 2>/dev/null | sed 's/\.$//g')
  else
    log_fail "Couldn't perform DNS lookup for replica set. DNS lookup utility doesn't exist"
    return 1
  fi

  if [[ -z "${addr:-}" ]]; then
    log_fail "Couldn't perform DNS lookup for replica set. No nodes listed in ${host}"
    return 1
  fi

  if (( $(grep -c . <<< "${addr}") > 1 )); then
    local i=0

    while read -r line; do
      if [[ "${i}" -eq "0" ]]; then
        addr="${line}"
      else
        addr="${line} ${addr}"
      fi

      let "i++"
    done <<< "${addr}"
  fi

  echo "${addr//[[:space:]]/,}"
}
readonly -f host2ipa

#----------------------------------------------------
# Usage
#----------------------------------------------------

# @public  Prints usage information about required enviroment variables.
#
# @param  $1 system log failure message
#
# 05/2021 Marked function as readonly.
function usage() {
  if [ $# == 1 ]; then
    log_fail "$1"
  fi

  echo "
  You must specify the following environment variables:
  SA_PASSWORD
  ACCEPT_EULA

  Optional settings:
  MSSQL_PID (default: Developer)
 
  For more information see /usr/share/container-scripts/mssql/README.md
  within the container or visit https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker?view=sql-server-ver15&pivots=cs1-bash."

  exit 1
}
readonly -f usage

#----------------------------------------------------
# Logger
#----------------------------------------------------

# @public System log information message.
#
# @param  $1 message details
function log_info() {
  printf "\xE2\x9E\xA1 [%s INFO] %s\n" "$(date +'%a %b %d %T')" "${1:-}"
}
readonly -f log_info

# @public System log failure message.
#
# @param  $1 message details
#
# 05/2017 Marked function as readonly.
function log_fail() {
  printf "\xe2\x9c\x98 [%s FAIL] %s\n" "$(date +'%a %b %d %T')" "${1:-}"
}
readonly -f log_fail

# @public System log success message.
#
# @param  $1 message details
#
# 05/2017 Marked function as readonly.
function log_pass() {
  printf "\xE2\x9C\x94 [%s PASS] %s\n" "$(date +'%a %b %d %T')" "${1:-}"
}
readonly -f log_pass
