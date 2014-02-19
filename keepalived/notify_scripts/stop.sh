#!/bin/bash
#
#
set -e
set -x

### require
. /vagrant/notify_scripts/common.sh

### function

### operation
if [[ -f /tmp/keepalived.state ]]; then
  rm /tmp/keepalived.state
fi

### stop zabbix-server
stop_service zabbix-server 
