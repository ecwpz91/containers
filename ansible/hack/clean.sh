#!/usr/bin/env bash

array=( jboss )

if [[ $1 == 'all' || $1 == 'containers' ]]; then
 printf "%s\n" "Removing all project containers..."

 for i in $(docker ps -a --format '{{.Names}}'); do
  for c in "${array[@]}"; do
   if [[ "${c:-}" == "${i:-}" ]]; then
    docker rm --force "${i:-}"
    found=true
   fi
  done

  [[ ! ${found:-} ]] &&  printf "No %s containers found\n" "${c}"; found=false
 done
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
