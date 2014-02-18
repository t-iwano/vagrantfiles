#!/bin/bash
#
# requires:
# bash
#
set -e
set -x

### require
. /vagrant/config.d/common.sh

### function
function add_packages() {
  addpkg="
    zabbix-agent-1.8.16
"
  if [[ -n "${addpkg}" ]]; then
    yum install -y ${addpkg}
  fi
}

### add repository
add_repositories list_zabbix

### add rpm packages
add_packages

