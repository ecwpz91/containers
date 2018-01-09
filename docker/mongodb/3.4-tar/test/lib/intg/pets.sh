#!/bin/bash

function test_mongo_pets() {
  local test_name=test-mongo-petset

  # Start OpenShift "oc cluster up" via wrapper script
  if echo -n $(oc-cluster status) | grep -o "no cluster running"; then
    oc-cluster up
  fi

  # Prepare image - add tag different than :latest (default imagePullPolicy is Always)
  dkr_tag ${IMAGE_NAME} ${IMAGE_NAME}:test-openshift

  echo "Pause to avoid race condition"
  sleep 5

  # [TODO]: Implement SELinux policy

  oc new-project ${test_name}
  oc new-app --file=${OS_PETSET_YAML} -p MONGODB_DATABASE=${MONGODB_USERDB} \
                                      -p MONGODB_USER=${MONGODB_USERID} \
                                      -p MONGODB_PASSWORD=${MONGODB_USERPW} \
                                      -p MONGODB_ADMIN_PASSWORD=${MONGODB_SUDOPW} \
                                      -p MONGODB_IMAGE=${IMAGE_NAME}:test-openshift \
                                      -p VOLUME_CAPACITY=${OS_VOLUME_CAPACITY}

  oc_wait_for_ready_pods "app=mongodb-petset-replication" 3
  oc_wait_for_ready_pods "openshift.io/deployer-pod-for.name" 0

  host="rs0/$(oc get endpoints mongodb --no-headers | tr -s ' ' | cut -f2 -d' ')"

  docker exec origin kubectl run --attach --restart=Never mongodb-test --image ${IMAGE_NAME}:test-openshift --env="MONGODB_ADMIN_PASSWORD=${MONGODB_SUDOPW}" --command -- bash -c "set -x
  . /usr/share/container-scripts/mongodb/common.sh
  . /usr/share/container-scripts/mongodb/test-functions.sh
  wait_for_mongo_up '${host}'
  wait_replicaset_members '${host}' 3
  insert_and_wait_for_replication '${host}' '{a:5, b:10}'"
}
