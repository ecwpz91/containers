#!/usr/bin/env bash

docker-remove() {
 local name=${1:-}
 local rslt

 if [[ -z "${name}" ]]; then
  rslt=( $(docker ps -aq) )
 else
  rslt=( "$(docker ps -aqf name=${name:-})" )
 fi

 if ! ${#rslt[@]}; then
  for c in "${rslt[@]}"; do
   if ! docker rm --force ${c} 2>/dev/null; then
    printf "fail: ${FUNCNAME[0]}: %s\n" "docker rm -it ${c} bash" >&2; return 1
   fi
  done
 fi
}

if [[ $1 == 'all' || $1 == 'containers' ]]; then
 echo "Removing all project containers..."
 containers=$(docker ps -a --format "{{.Names}}" | grep -e ansible_jboss | wc -l | tr -d '[[:space:]]')
 if [ ${containers} -gt 0 ]; then
  docker rm --force $(docker ps -a --format "{{.Names}}" | grep -e ansible_jboss)
 else
  echo "No ansible_jboss containers found"
 fi
fi

if [[ $1 == 'all' || $1 == 'images' ]]; then
 project_name=$(basename $(python -c "from os import path; print(path.abspath(path.join(path.dirname('$0'), '..')))"))
 echo "Removing all ${project_name} images..."
 images=$(docker images -a --format "{{.Repository}}:{{.Tag}}" | grep ${project_name} | wc -l | tr -d '[[:space:]]')
 if [ ${images} -gt 0 ]; then
  docker rmi --force $(docker images -a --format "{{.Repository}}:{{.Tag}}" | grep ${project_name})
 else
  echo "No ${project_name} images found"
 fi
fi
