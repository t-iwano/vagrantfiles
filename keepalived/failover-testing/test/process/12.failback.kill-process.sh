#!/bin/bash
#
# requires:
#  bash
#

## include files

. ${BASH_SOURCE[0]%/*}/helper_shunit2.sh
. ${BASH_SOURCE[0]%/*}/helper_failover.sh

## variables
master=${BACKUP_HOST}
backup=${MASTER_HOST}

## function

function test_before_check() {
  check_master
  check_backup
}

function test_failover_stop_process() {
  kill_keepalived ${master}
  assertEquals 0 $?

  wait_sec 60
  echo "failback finished"
}

function test_after_check() {
  check_new_backup_kill
  check_new_master
}

## shunit2

. ${shunit2_file}
