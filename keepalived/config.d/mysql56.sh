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
    mysql-community-server mysql-community-client
"
  if [[ -n "${addpkg}" ]]; then
    yum install -y ${addpkg}
  fi
}

function setup_slave() {
  /usr/bin/mysqlreplicate --master=root@192.168.51.11 --slave=root@192.168.51.12 --rpl-user=repl:repl --start-from-beginning
}

### add repository
add_repositories list_mysqld

### add rpm packages
add_packages

### delete mysqldir
delete_mysqldir

### create my.cnf
check_mycnf
build_mycnf

### start mysqld
start_service mysqld

### importdb
import_sql

### restart mysqld
restart_service mysqld

### setup slave
setup_slave
