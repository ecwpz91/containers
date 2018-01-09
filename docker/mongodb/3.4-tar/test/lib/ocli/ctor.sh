#!/bin/bash

function oc_wait_for_ready_pods() {
  local label=${1:-}
  local count=${2:-}
  local i=1

  until [[ "$(oc get pods --no-headers=true -l "${label}" | grep "1/1" | wc -l)" -eq "${count}" ]] || \
  [ $i -eq ${MAX_ATTEMPT} ]; do
    log_info "Waiting for ${count} ready pods with '${label}' label"
    sleep $(( i++ ))
  done
}

function oc_setup_client() {
  if [[ ! -d ${OS_CLIENT_DIR} ]]; then
    OC_RELEASE=$(curl -s https://api.github.com/repos/openshift/origin/releases | grep "browser_download_url" | grep "openshift-origin-client" | grep "linux-64bit" | sort | tail -n 1 | sed -e 's|"browser_download_url": ||' | tr -d ' "')

    mkdir ${OS_CLIENT_DIR}
    curl -L ${OC_RELEASE} | tar -xzf - -C ${OS_CLIENT_DIR} --strip 1
    curl -L 'https://github.com/openshift-evangelists/oc-cluster-wrapper/tarball/master' | tar -xzf - -C ${OS_CLIENT_DIR} --strip 1
  fi

  export PATH=${OS_CLIENT_DIR}:${PATH}
}

function oc_error() {
  oc get all
  while read pod_info; do
    pod=$(echo ${pod_info} | tr -s ' ' | cut -f1 -d' ')
    log_info "printing logs for pod ${pod}"
    oc logs ${pod}
  done < $(oc get pods --no-headers=true)
}

function oc_shutdown() {
  log_info "Stopping & removing OC cluster"
  oc cluster down
  echo y | oc-cluster destroy
}
