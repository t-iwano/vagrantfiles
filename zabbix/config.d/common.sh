#!/bin/bash
#
# requires:
# bash
#
set -e

### service
function start_service() {
  local name=$1
  [[ -n ${name} ]] || return 1
  /etc/init.d/${name} start
}

function stop_service() {
  local name=$1
  [[ -n ${name} ]] || return 1
  /etc/init.d/${name} stop
}

function restart_service() {
  local name=$1
  [[ -n ${name} ]] || return 1
  /etc/init.d/${name} restart
}

### mysqld
function init_db() {
  yes | mysqladmin -uroot drop zabbix || :
  mysqladmin -uroot create zabbix --default-character-set=utf8;
}

function create_user() {
  mysql -uroot <<EOS
grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';
flush privileges;
EOS
}

function import_zabbix_data() {
  local zabbix_ver=$(rpm -qa zabbix-server | awk -F\- '{print $3}')
  [[ -n ${zabbix_ver} ]] || return 1
  mysql -uroot zabbix < /usr/share/doc/zabbix-server-mysql-${zabbix_ver}/create/schema/mysql.sql
  mysql -uroot zabbix < /usr/share/doc/zabbix-server-mysql-${zabbix_ver}/create/data/data.sql
  mysql -uroot zabbix < /usr/share/doc/zabbix-server-mysql-${zabbix_ver}/create/data/images_mysql.sql
}

function setup_zabbix_serverconf() {
  if ! grep -q "DBPassword=zabbix" /etc/zabbix/zabbix_server.conf >/dev/null; then
    echo "DBPassword=zabbix" >> /etc/zabbix/zabbix_server.conf
  fi
}

function setup_timezone() {
  cp /vagrant/files/php.ini /etc/php.ini
}

### yum
function yum() {
  $(type -P yum) "${@}"
}

### packages
function list_mysqld() {
  cat <<EOS | egrep -v ^#
# pkg_name                           pkg_uri
mysql-community-release-el6-5.noarch http://repo.mysql.com/mysql-community-release-el6-5.noarch.rpm
mysql-utilities-1.3.6-1.el6.noarch   http://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-utilities-1.3.6-1.el6.noarch.rpm
EOS
}

function list_zabbix() {
  cat <<EOS | egrep -v ^#
# pkg_name                           pkg_uri
zabbix-release-1.8-1.el6.noarch      http://repo.zabbix.com/zabbix/1.8/rhel/6/x86_64/zabbix-release-1.8-1.el6.noarch.rpm
EOS
}

function list_zabbix2.2() {
  cat <<EOS | egrep -v ^#
# pkg_name                           pkg_uri
zabbix-release-2.2-1.el6.noarch      http://repo.zabbix.com/zabbix/2.2/rhel/6/x86_64/zabbix-release-2.2-1.el6.noarch.rpm
EOS
}

function add_repositories() {
  local reponame=$1
  if [[ -n "${reponame}" ]]; then
    ${reponame} | while read pkg_name pkg_uri; do
      rpm -qi ${pkg_name} >/dev/null || yum install -y ${pkg_uri}
    done
  fi
}

function add_packages() {
  addpkg="
    mysql-community-server mysql-community-client
    zabbix-server-mysql zabbix-web-mysql zabbix-web-japanese zabbix-agent
"
  if [[ -n "${addpkg}" ]]; then
    yum install -y ${addpkg}
  fi
}

