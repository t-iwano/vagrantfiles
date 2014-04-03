#!/bin/bash
#
#
set -e
set -x

### require
. /vagrant/notify_scripts/common.sh
. /root/secure/root

### function
function setup_replication() {
  reset_slave

  # check semi sync slave status
  check_semi_repl_status slave OFF || {
    set_semi_sync_status slave 0
  }

  # set semi sync master timeout
  set_semi_sync_master_timeout

  # check semi sync master status
  check_semi_repl_status master ON || {
    set_semi_sync_status master 1
  }
}

### operation
setup_vars

### start mysqld
start_service mysqld

### setup replication
setup_replication

### start zabbix-server
start_service zabbix-server

### start httpd
start_service httpd

