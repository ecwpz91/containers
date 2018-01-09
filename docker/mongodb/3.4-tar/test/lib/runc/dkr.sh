#!/bin/bash

# List containers
function dkr_ps() { docker ps "$@"; }
readonly -f dkr_ps

# Inspect low-level info
function dkr_ins() { docker inspect "$@"; }
readonly -f dkr_ins

function dkr_ins_ip() { docker inspect --format '{{ .NetworkSettings.IPAddress }}' "$@"; }
readonly -f dkr_ins_ip

function dkr_ins_ports() { docker inspect --format='{{.Config.ExposedPorts}}' "$@"; }
readonly -f dkr_ins_ports

function dkr_ins_image() { docker inspect --format='{{.Config.Image}}' "$@"; }
readonly -f dkr_ins_image

# Initialize container
function dkr_run() { docker run "$@"; }
readonly -f dkr_run

# Run command in container
function dkr_exec() { docker exec "$@"; }
readonly -f dkr_exec

# Stop container
function dkr_stop() { docker stop "$@"; }
readonly -f dkr_stop

# Remove container
function dkr_rm() { docker rm "$@"; }
readonly -f dkr_rm

# Remove image
function dkr_rmi() { docker rmi "$@"; }
readonly -f dkr_rmi

# Manage volume
function dkr_vol() { docker volume "$@"; }
readonly -f dkr_vol

function dkr_vol_rm() { docker volume rm "$@"; }
readonly -f dkr_vol_rm

function dkr_vol_ls() { docker volume ls "$@"; }
readonly -f dkr_vol_ls

# Tag image
function dkr_tag() { docker tag "$@"; }
readonly -f dkr_tag

# Fetch container logs
function dkr_logs() { docker logs "$@"; }
readonly -f dkr_logs
