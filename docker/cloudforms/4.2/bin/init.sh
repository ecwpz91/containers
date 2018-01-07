#!/bin/bash

DIR="$(dirname "${BASH_SOURCE[0]}")"
URI=""

wget -N $URI -P $DIR/../root/tmp

docker build -t demo/cfme:4.2 .
