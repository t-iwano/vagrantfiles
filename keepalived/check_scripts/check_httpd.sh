#!/bin/bash
#
#
set -x

state=$(cat /tmp/keepalived.state)
case "${state}" in
MASTER)
  killall -0 httpd
  ;;
BACKUP)
  /etc/init.d/httpd status | grep stopped
  ;;
FAULT)
  ;;
esac

