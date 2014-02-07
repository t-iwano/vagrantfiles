#!/bin/bash
#
#
set -e
set -x

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

function reset_slave() {
  /usr/bin/mysqlrpladmin reset --slaves=root@${slave_ip}
}

function setup_slave() {
  /usr/bin/mysqlreplicate --master=root@${master_ip} --slave=root@${slave_ip} --rpl-user=repl:repl --start-from-beginning
}

function query_mysql() {
  /usr/bin/mysql -uroot
}

function check_semi_repl_status() {
  local name=$1
  local value=$2
  [[ -n ${name} ]] || return 1
  [[ -n ${value} ]] || return 1
  echo "show variables like 'rpl_semi_sync_${name}_enabled'" | query_mysql | grep ${value}
}

function set_semi_sync_status() {
  local name=$1
  local value=$2
  [[ -n ${name} ]] || return 1
  [[ -n ${value} ]] || return 1
  echo "set global rpl_semi_sync_${name}_enabled=${value}" | query_mysql
}

function setup_replication() {
  # stop slave
  reset_slave

  # check semi sync slave status
  check_semi_repl_status slave ON || {
    set_semi_sync_status slave 1
  }

  # set semi sync master timeout
  echo "set global rpl_semi_sync_master_timeout=30" | query_mysql

  # check semi sync master status
  check_semi_repl_status master OFF || {
    set_semi_sync_status master 0
  }

  # setup slave
  setup_slave
}


### setup params
hostname=`hostname -s`
case "${hostname}" in
keepalived01)
  master_ip=192.168.51.11
  slave_ip=192.168.51.10
  ;;
keepalived02)
  master_ip=192.168.51.10
  slave_ip=192.168.51.11
  ;;
esac

### start mysqld
start_service mysqld

### setup replication
setup_replication

### start zabbix-server
stop_service zabbix-server

### start httpd
stop_service httpd

