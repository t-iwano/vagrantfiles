#!/bin/bash
#
# requires:
#  bash
#

## include files

. ${BASH_SOURCE[0]%/*}/helper_shunit2.sh
. ${BASH_SOURCE[0]%/*}/helper_failover.sh

## variables
master=${MASTER_HOST}
backup=${BACKUP_HOST}
pifname=${PUBLIC_INTERFACE}
wifname=${WAKAME_INTERFACE}

## function

function oneTimeTearDown() {
  show_physical_ipaddr ${master} ${pifname} || {
    up_interface ${master} ifname=${pifname}
    wait_sec 60
  }
}

function test_before_check() {
  before_check_master_process
  before_check_backup_process
  before_check_master_interface
  before_check_backup_interface
}

function test_failover_stop_process() {
  down_interface ${master} ifname=${pifname}
  assertEquals 0 $?

  wait_sec 60
  echo "failover finished"
}

function test_after_check() {
  after_check_backup_process
  after_check_master_process
  after_check_backup_interface
  after_check_master_interface
}

## shunit2

. ${shunit2_file}
