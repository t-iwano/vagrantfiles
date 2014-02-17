#!/bin/bash
#
# requires:
# bash
#
set -e
set -x


### variables

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

### create database zabbix
create_db

### create replication user and zabbix user
create_user

### install plugins
install_plugins

### import zabbix data
import_zabbix_data

### sql dump initial data
dump_sql

### setup zabbix conf php
check_zabbixconf
setup_zabbixconf

### setup zabbix server conf
setup_zabbix_serverconf

### setup timezone
setup_timezone

### setup keepalived
check_keepalivedconf
setup_keepalivedconf
