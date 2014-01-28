#!/bin/bash
#
#
set -x

state=$(cat /tmp/keepalived.state)
case "${state}" in
MASTER)
  killall -0 zabbix_server
  ;;
BACKUP)
  /etc/init.d/zabbix-server status | grep stopped
  ;;
FAULT)
  ;;
esac
