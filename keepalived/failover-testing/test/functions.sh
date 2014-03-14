#!/bin/bash
#
# requires:
#  bash
#

# funcitons

## common

function run_in_target() {
  local node=${1}; shift
  vagrant ssh ${node} -c "${@}"
}

function show_ipaddr() {
  local node=${1}
  shift; eval local "${@}"
  run_in_target ${node} "ip addr show ${ifname} | grep -w inet"
}

## keepalived

function start_keepalived() {
  local node=${1}
  run_in_target ${node} "sudo service keepalived start"
}

function stop_keepalived() {
  local node=${1}
  run_in_target ${node} "sudo service keepalived stop"
}

function restart_keepalived() {
  local node=${1}
  run_in_target ${node} "sudo service keepalived restart"
}

function status_keepalived() {
  local node=${1}
  run_in_target ${node} "sudo service keepalived status" | awk '{print $NF}'
}

function kill_keepalived() {
  local node=${1}
  run_in_target ${node} "sudo pkill -f keepalived"
}

## httpd

function status_httpd() {
  local node=${1}
  run_in_target ${node} "sudo service httpd status" | awk '{print $NF}'
}

## zabbix-server

function status_zabbix() {
  local node=${1}
  run_in_target ${node} "sudo service zabbix-server status" | awk '{print $NF}'
}

## mysqld

function status_mysqld() {
  local node=${1}
  run_in_target ${node} "sudo service mysqld status"  | awk '{print $NF}'
}


