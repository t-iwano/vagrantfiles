#!/bin/bash
#
#
set -e

### service
function start_service() {
  local name=$1
  [[ -n ${name} ]] || return 1
  /etc/init.d/${name} status | grep -q running || {
    /etc/init.d/${name} start
  }
}

function stop_service() {
  local name=$1
  [[ -n ${name} ]] || return 1
  /etc/init.d/${name} status | grep -q stopped || {
    /etc/init.d/${name} stop
  }
}

function restart_service() {
  local name=$1
  [[ -n ${name} ]] || return 1
  /etc/init.d/${name} restart
}

### mysqld
function query_mysql() {
  /usr/bin/mysql -uroot
}

function check_semi_repl_status() {
  local name=$1
  local value=$2
  [[ -n ${name}  ]] || return 1
  [[ -n ${value} ]] || return 1
  echo "show variables like 'rpl_semi_sync_${name}_enabled'" | query_mysql | grep ${value}
}

function set_semi_sync_status() {
  local name=$1
  local value=$2
  [[ -n ${name}  ]] || return 1
  [[ -n ${value} ]] || return 1
  echo "set global rpl_semi_sync_${name}_enabled=${value}" | query_mysql
}

function set_semi_sync_master_timeout() {
  echo "set global rpl_semi_sync_master_timeout=30" | query_mysql
}

function stop_slave() {
  echo "stop slave" | query_mysql
}

function reset_slave() {
  stop_slave
  echo "reset slave all" | query_mysql
}

function setup_slave() {
  local master_ip=$1
  local slave_ip=$2
  [[ -n ${master_ip}  ]] || return 1
  [[ -n ${slave_ip} ]] || return 1
  /usr/bin/mysqlreplicate --master=root@${master_ip} --slave=root@${slave_ip} --rpl-user=repl:repl --start-from-beginning
}
