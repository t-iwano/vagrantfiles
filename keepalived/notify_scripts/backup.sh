#!/bin/bash
#
#
set -e
set -x

### require
. /vagrant/notify_scripts/common.sh

### function
function setup_replication() {
  reset_slave

  # check semi sync master status
  check_semi_repl_status master OFF || {
    set_semi_sync_status master 0
  }

  # check semi sync slave status
  check_semi_repl_status slave ON || {
    set_semi_sync_status slave 1
  }

  # setup slave
  setup_slave ${master_ip} ${slave_ip}
}

### operation

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

### stop httpd
stop_service httpd

### stop zabbix-server
stop_service zabbix-server

### start mysqld
start_service mysqld

### setup replication
setup_replication

