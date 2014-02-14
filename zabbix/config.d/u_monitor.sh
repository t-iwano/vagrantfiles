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

### start mysqld
start_service mysqld

### create database zabbix
init_db

### create zabbix user
create_user

### import zabbix data
import_zabbix_data

### setup zabbix conf php

### setup zabbix server conf
setup_zabbix_serverconf

### setup timezone
#setup_timezone

### start zabbix
start_service zabbix-server

### start httpd
start_service httpd
