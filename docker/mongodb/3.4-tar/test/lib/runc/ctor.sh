#!/bin/bash

# @public Creates a new container with the given name.
#
# @param  container this container's name
# @param  baseimage repository of this container's base image
function run_container() {
  local container=${1:-}
  local baseimage=${2:-}; shift 2 || return 1

  dkr_run --name ${container} -d "$@" ${baseimage}
  wait_for_container ${container}
}
readonly -f run_container

# @public Creates a new container with the given name and runs entry command.
#
# @param  container this container's name
# @param  baseimage repository of this container's base image
function run_container_entcomm() {
  local container=${1:-}
  local baseimage=${2:-}
  local entrycomm=${3:-}; shift 3 || return 1

  dkr_run --name ${container} -d "$@" ${baseimage} ${entrycomm}
  wait_for_container ${container}
}
readonly -f run_container_entcomm

# @public Creates a new container with the given name and runs for specified time period.
#
# @param  container this container's name
# @param  baseimage repository of this container's base image
# @param  timelimit floating point number in seconds
function run_container_timeout() {
  local container=${1:-}
  local baseimage=${2:-}
  local timelimit=${3:-}; shift 3 || return 1

  timeout ${timelimit}s docker run --name ${container} -d "$@" ${baseimage}
}
readonly -f run_container_entcomm

# @public Logs, stops, and removes this container.
#
# @param  container this container's name
function stop_container() {
  local container=$(get_container_id ${1:-})

  for cid in ${container}; do
    dkr_logs ${cid}
    dkr_stop ${cid}
    dkr_rm -v ${cid}
  done
}
readonly -f stop_container

# @public Wait for this conatiner to be running.
#
# @param  container this container's name
function wait_for_container() {
  local container=${1:-}; shift || return 1
  local i=1

  until [[ "$(dkr_ps -aqf name=${container} --no-trunc)" != "" ]] || \
        [[ ${i} -eq 10 ]]; do
    sleep $(( i++ ))
  done
}
readonly -f wait_for_container

# @public Creates a new container and gets timeout status of this container's run command.
#
# @param  baseimage repository of this container's base image
# @param  timelimit floating point number in seconds
# @param  outsignal signal sent if this conatiner's run command times out
# @return integer status of this container's run command
function get_run_container_timeout_status() {
  local baseimage=${1:-}
  local timelimit=${2:-};
  local outsignal=${3:-}; shift 3 || return 1

  echo -n $(timeout -s ${outsignal} --preserve-status ${timelimit}s docker run --rm "$@" ${baseimage} &>/dev/null; echo -n $? | grep -so "[0-9]*")
}
readonly -f get_run_container_timeout_status

# @public Gets this container's ID.
#
# @param  container this container's name
# @return this container's ID
function get_container_id() {
  local container=${1:-}; shift || return 1

  echo -n $(dkr_ps -aqf name=${container} --no-trunc)
}
readonly -f get_container_id

# @public Gets the IP address of this continer.
#
# @param  container this container's name
# @return this conatiner's IP address
function get_container_ip() {
  local container=$(get_container_id ${1:-})

  echo -n $(dkr_ins_ip ${container})
}
readonly -f get_container_ip

# @public Gets this base image ports.
#
# @param  baseimage this base image's name
# @return this base image's ports
function get_image_ports() {
  local baseimage=${1:-}; shift || return 1
  local ports_map=$(dkr_ins_ports ${baseimage} | grep -so "[0-9]*")
  local baseports=""

  for port in ${ports_map}; do
    baseports="${baseports} -p ${port}:${port}"
  done

  echo -n ${baseports}
}
readonly -f get_image_ports

# @public Gets this container's ports.
#
# @param  container this container's name
# @return this container's ports
function get_container_ports() {
  local container=$(get_container_id ${1:-})
  local baseimage=$(dkr_ins_image ${container})

  echo -n $(get_image_ports ${baseimage})
}
readonly -f get_container_ports
