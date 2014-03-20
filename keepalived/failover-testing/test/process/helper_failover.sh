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
    wait_sec 60
  }

  status_keepalived ${backup} | grep -w running || {
    start_keepalived ${backup} 
    wait_sec 60
  }
}

function oneTimeTearDown() {
  status_keepalived ${master} | grep -w "stopped\|locked" && {
    start_keepalived ${master}
    wait_sec 120
  }
}

function before_check_master_process() {
  status=$(status_mysqld     ${master})
  assertEquals "running..." "${status}"
  status=$(status_zabbix     ${master})
  assertEquals "running..." "${status}"
  status=$(status_httpd      ${master})
  assertEquals "running..." "${status}"
  status=$(status_keepalived ${master})
  assertEquals "running..." "${status}"
}

function before_check_backup_process() {
  status=$(status_mysqld     ${backup})
  assertEquals "running..." "${status}"
  status=$(status_zabbix     ${backup})
  assertEquals "stopped"    "${status}"
  status=$(status_httpd      ${backup})
  assertEquals "running..." "${status}"
  status=$(status_keepalived ${backup})
  assertEquals "running..." "${status}"
}

function after_check_master_process() {
  status=$(status_mysqld     ${backup})
  assertEquals "running..." "${status}"
  status=$(status_zabbix     ${backup})
  assertEquals "running..." "${status}"
  status=$(status_httpd      ${backup})
  assertEquals "running..." "${status}"
  status=$(status_keepalived ${backup})
  assertEquals "running..." "${status}"
}

function after_check_backup_process() {
  status=$(status_mysqld     ${master})
  assertEquals "stopped"    "${status}"
  status=$(status_zabbix     ${master})
  assertEquals "stopped"    "${status}"
  status=$(status_httpd      ${master})
  assertEquals "stopped"    "${status}"
  status=$(status_keepalived ${master})
  assertEquals "stopped"    "${status}"
}

function before_check_master_interface() {
  show_virtual_ipaddr ${master} ${pifname}
  assertEquals 0 $?
  show_virtual_ipaddr ${master} ${wifname}
  assertEquals 0 $?
}

function before_check_backup_interface() {
  show_virtual_ipaddr ${backup} ${pifname}
  assertEquals 1 $?
  show_virtual_ipaddr ${backup} ${wifname}
  assertEquals 1 $?
}

function after_check_master_interface() {
  show_virtual_ipaddr ${backup} ${pifname}
  assertEquals 0 $?
  show_virtual_ipaddr ${backup} ${wifname}
  assertEquals 0 $?
}

function after_check_backup_interface() {
  show_virtual_ipaddr ${master} ${pifname}
  assertEquals 1 $?
  show_virtual_ipaddr ${master} ${wifname}
  assertEquals 1 $?
}

function before_check_master_repl() {
  enabled=$(check_rpl_variables ${master} name="master" value="enabled")
  assertEquals "ON"  "${enabled}"
  enabled=$(check_rpl_variables ${master} name="slave"  value="enabled")
  assertEquals "OFF" "${enabled}"
  status=$(check_rpl_status ${master} name="master")
  assertEquals "ON" "${status}"
  status=$(check_rpl_status ${master} name="slave" )
  assertEquals "OFF" "${status}"
}

function before_check_backup_repl() {
  enabled=$(check_rpl_variables ${backup} name="master" value="enabled")
  assertEquals "OFF" "${enabled}"
  enabled=$(check_rpl_variables ${backup} name="slave"  value="enabled")
  assertEquals "ON"  "${enabled}"
  status=$(check_rpl_status ${backup} name="master")
  assertEquals "OFF" "${status}"
  status=$(check_rpl_status ${backup} name="slave" )
  assertEquals "ON"  "${status}"
}

function after_check_master_repl() {
  enabled=$(check_rpl_variables ${backup} name="master" variable="enabled")
  assertEquals "ON"  "${enabled}"
  enabled=$(check_rpl_variables ${backup} name="slave"  variable="enabled")
  assertEquals "OFF" "${enabled}"
  status=$(check_rpl_status ${backup} name="master")
  assertEquals "ON"  "${status}"
  status=$(check_rpl_status ${backup} name="slave" )
  assertEquals "OFF" "${status}"
}

function wait_sec() {
  local sec=${1}
  echo "wait ${sec} sec"
  sleep ${sec}
}
