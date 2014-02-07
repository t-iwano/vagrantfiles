#!/bin/bash
#
# requires:
# bash
#
set -e
set -x

### require
. /vagrant/bootstrap.d/common.sh

### function
function yum() {
  $(type -P yum) "${@}"
}

function list_3rd_party() {
  cat <<EOS | egrep -v ^#
# pkg_name                           pkg_uri
mysql-community-release-el6-5.noarch http://repo.mysql.com/mysql-community-release-el6-5.noarch.rpm
zabbix-release-2.2-1.el6.noarch      http://repo.zabbix.com/zabbix/2.2/rhel/6/x86_64/zabbix-release-2.2-1.el6.noarch.rpm
mysql-utilities-1.3.6-1.el6.noarch   http://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-utilities-1.3.6-1.el6.noarch.rpm
EOS
}

## add 3rd party rpm packages
list_3rd_party | while read pkg_name pkg_uri; do
  rpm -qi ${pkg_name} >/dev/null || yum install -y ${pkg_uri}
done

# add rpm packages
addpkgs="
 keepalived
 mysql-community-server mysql-community-client
 zabbix-server-mysql zabbix-web-mysql zabbix-get zabbix-web-japanese
"
if [[ -n "${addpkgs}" ]]; then
  yum install -y ${addpkgs}
fi

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

