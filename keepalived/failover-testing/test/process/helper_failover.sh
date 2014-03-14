#!/bin/bash
#
# requires:
#  bash
#

## include files

## variables

## functions

### failover

function oneTimeSetUp() {
  status_keepalived ${master} | grep -w running || {
    start_keepalived ${master} 
    wait_sec 30
  }

  status_keepalived ${backup} | grep -w running || {
    start_keepalived ${backup} 
    wait_sec 30
  }
}

function oneTimeTearDown() {
  status_keepalived ${master} | grep -w "stopped\|locked" && {
    start_keepalived ${master}
    wait_sec 60
  }
}

function check_master() {
  status=$(status_mysqld     ${master})
  assertEquals "running..." "${status}"
  status=$(status_zabbix     ${master})
  assertEquals "running..." "${status}"
  status=$(status_httpd      ${master})
  assertEquals "running..." "${status}"
  status=$(status_keepalived ${master})
  assertEquals "running..." "${status}"
}

function check_backup() {
  status=$(status_mysqld     ${backup})
  assertEquals "running..." "${status}"
  status=$(status_zabbix     ${backup})
  assertEquals "stopped"    "${status}"
  status=$(status_httpd      ${backup})
  assertEquals "running..." "${status}"
  status=$(status_keepalived ${backup})
  assertEquals "running..." "${status}"
}

function check_new_master() {
  status=$(status_mysqld     ${backup})
  assertEquals "running..." "${status}"
  status=$(status_zabbix     ${backup})
  assertEquals "running..." "${status}"
  status=$(status_httpd      ${backup})
  assertEquals "running..." "${status}"
  status=$(status_keepalived ${backup})
  assertEquals "running..." "${status}"
}

function check_new_backup() {
  status=$(status_mysqld     ${master})
  assertEquals "stopped"    "${status}"
  status=$(status_zabbix     ${master})
  assertEquals "stopped"    "${status}"
  status=$(status_httpd      ${master})
  assertEquals "stopped"    "${status}"
  status=$(status_keepalived ${master})
  assertEquals "stopped"    "${status}"
}

function check_new_backup_kill() {
  status=$(status_mysqld     ${master})
  assertEquals "stopped"    "${status}"
  status=$(status_zabbix     ${master})
  assertEquals "stopped"    "${status}"
  status=$(status_httpd      ${master})
  assertEquals "stopped"    "${status}"
  status=$(status_keepalived ${master})
  assertEquals "locked"    "${status}"
}

function wait_sec() {
  local sec=${1}
  echo "wait ${sec} sec"
  sleep ${sec}
}
