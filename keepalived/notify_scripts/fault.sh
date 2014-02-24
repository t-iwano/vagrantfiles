#!/bin/bash
#
#
set -e
set -x

### require
. /vagrant/notify_scripts/common.sh

### function

### operation

### stop mysqld
stop_service mysqld

### stop zabbix-server
stop_service zabbix-server

### stop httpd
stop_service httpd

