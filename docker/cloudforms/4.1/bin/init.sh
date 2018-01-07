#!/bin/bash

DIR="$(dirname "${BASH_SOURCE[0]}")"
VDB_URI=""
V2K_URI=""


wget -N $VDB_URI -P $DIR/../root/tmp

wget -N $V2K_URI -P $DIR/../root/var/www/miq/vmdb/certs/

docker build -t demo/cfme:4.1 .
