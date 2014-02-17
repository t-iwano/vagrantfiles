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

### add repository
add_repositories list_mysqld
add_repositories list_zabbix

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

### setup zabbix conf php
check_zabbixconf
setup_zabbixconf

### setup zabbix server conf
setup_zabbix_serverconf

### setup timezone
setup_timezone

### restart mysqld
restart_service mysqld

### setup keepalived
check_keepalivedconf
setup_keepalivedconf

