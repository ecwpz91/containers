#!/bin/bash

# Max
readonly MAX_TIMEOUT=30
readonly MAX_ATTEMPT=10
readonly MAX_SLEEP=2

# Directory
readonly MONGODB_DATADIR_PATH="/var/lib/mongodb/data"
readonly OS_CLIENT_DIR="${OS_ROOT}/../os-client"
readonly OS_VOLUME_DIR="${OS_ROOT}/../os-volume"
readonly OS_EXAMPLE_DIR="${OS_ROOT}/../examples"

# File
readonly MONGODB_SOCKET_FILE="/tmp/mongodb-27017.sock"
readonly MONGODB_CONFIG_FILE="/etc/mongod.conf"
readonly OS_PETSET_YAML="${OS_EXAMPLE_DIR}/petset/mongodb-petset-persistent.yaml"

# User methods
readonly MONGODB_USERCMD_PREFIX="db"
readonly MONGODB_USERCMD_DROP_DATABASE="${MONGODB_USERCMD_PREFIX}.dropDatabase()"
readonly MONGODB_USERCMD_VERSION="${MONGODB_USERCMD_PREFIX}.version()"

# Admin methods
readonly MONGODB_ADMINCMD_PREFIX="${MONGODB_USERCMD_PREFIX}=${MONGODB_USERCMD_PREFIX}"

# Test data methods
readonly MONGODB_TESTCMD_PREFIX="${MONGODB_USERCMD_PREFIX}.testData"
readonly MONGODB_TESTCMD_COUNT="${MONGODB_TESTCMD_PREFIX}.count()"
readonly MONGODB_TESTCMD_FIND_ALL="${MONGODB_TESTCMD_PREFIX}.find()"
readonly MONGODB_TESTCMD_FIND_ALL_JSON="${MONGODB_TESTCMD_FIND_ALL}.forEach(printjson)"
readonly MONGODB_TESTCMD_DROP="${MONGODB_TESTCMD_PREFIX}.drop()"

# Configuration
readonly OS_VOLUME_CAPACITY="500M"
