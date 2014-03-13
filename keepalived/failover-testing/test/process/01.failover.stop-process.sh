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

## function

function test_before_check() {
  status=$(status_mysqld     ${master})
  assertEquals "running..." "${status}"
  status=$(status_zabbix     ${master})
  assertEquals "running..." "${status}"
  status=$(status_httpd      ${master})
  assertEquals "running..." "${status}"
  status=$(status_keepalived ${master})
  assertEquals "running..." "${status}"

  status=$(status_mysqld     ${backup})
  assertEquals "running..." "${status}"
  status=$(status_zabbix     ${backup})
  assertEquals "stopped"    "${status}"
  status=$(status_httpd      ${backup})
  assertEquals "running..." "${status}"
  status=$(status_keepalived ${backup})
  assertEquals "running..." "${status}"
}

function test_failover_stop_process() {
  stop_keepalived ${master}
  assertEquals 0 $?

  echo "wait failover finished 60sec..."
  sleep 60
}

function test_after_check() {
  status=$(status_mysqld     ${master})
  assertEquals "stopped"    "${status}"
  status=$(status_zabbix     ${master})
  assertEquals "stopped"    "${status}"
  status=$(status_httpd      ${master})
  assertEquals "stopped"    "${status}"
  status=$(status_keepalived ${master})
  assertEquals "stopped"    "${status}"

  status=$(status_mysqld     ${backup})
  assertEquals "running..." "${status}"
  status=$(status_zabbix     ${backup})
  assertEquals "running..." "${status}"
  status=$(status_httpd      ${backup})
  assertEquals "running..." "${status}"
  status=$(status_keepalived ${backup})
  assertEquals "running..." "${status}"
}

## shunit2

. ${shunit2_file}
