#!/bin/bash
#
#
set -e

### setup
function setup_vars() {
  MYSQL_USER=${MYSQL_USER:-root}
  MYSQL_PASSWORD=${MYSQL_PASSWORD:-}
  REPL_USER=${REPL_USER:-repl}
  REPL_PASSWORD=${REPL_PASSWORD:-repl}
}

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
  declare mysql_opts=""
  [[ -n "${MYSQL_PASSWORD}" ]] && {
    mysql_opts="${mysql_opts} --password=${MYSQL_PASSWORD}"
  }
  /usr/bin/mysql -s ${mysql_opts} -u${MYSQL_USER}
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
  echo "set global rpl_semi_sync_master_timeout=5000" | query_mysql
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
  /usr/bin/mysqlreplicate --master=${MYSQL_USER}@${master_ip} --slave=${MYSQL_USER}@${slave_ip} --rpl-user=${REPL_USER}:${REPL_PASSWORD} --start-from-beginning
}
