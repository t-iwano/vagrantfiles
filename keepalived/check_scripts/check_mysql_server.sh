#!/bin/bash
#
#
set -x

state=$(cat /tmp/keepalived.state)
case "${state}" in
MASTER|BACKUP)
  killall -0 mysqld
  ;;
FAULT)
  ;;
esac
