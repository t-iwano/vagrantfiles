#!/bin/bash
#
#
set -e

### yum
function yum() {
  $(type -P yum) "${@}"
}

### mysqld
function delete_mysqldir() {
  local mysqldir=/var/lib/mysql
  if [[ -d ${mysqldir} ]]; then
    rm -rf ${mysqldir}
    mkdir ${mysqldir}
    chown -R mysql:mysql ${mysqldir}
  fi
}

function check_mycnf() {
  if [[ -f /etc/mycnf ]]; then
    mv /etc/my.cnf /etc/my.cnf.`date +%Y%m%d`
  fi
}

function build_mycnf() {
  local hostname=`hostname -s`
  case "${hostname}" in
  keepalived01)
    server_id=100
    report_host=192.168.51.10
    ;;
  keepalived02)
    server_id=101
    report_host=192.168.51.11
    ;;
  mysql56)
    server_id=102
    report_host=192.168.51.12
    ;;
  esac
  cat <<EOS > "/etc/my.cnf"
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
symbolic-links=0
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
server_id=${server_id}
log-bin=mysql-bin
log-slave-updates
gtid-mode=ON
enforce-gtid-consistency
master_info_repository=TABLE
relay_log_info_repository=TABLE
report_host=${report_host}
skip-slave-start

[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
EOS
}

function create_db() {
  mysql -uroot <<EOS
create database zabbix character set utf8;
EOS
}

function create_user() {
  mysql -uroot <<EOS
grant replication slave on *.* to repl@'192.168.51.10' identified by 'repl';
grant replication slave on *.* to repl@'192.168.51.11' identified by 'repl';
grant replication slave on *.* to repl@'192.168.51.12' identified by 'repl';
grant all on *.* to root@'%' with grant option;
grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';
flush privileges;
EOS
}

function install_plugins() {
  mysql -uroot <<EOS
install plugin rpl_semi_sync_master soname 'semisync_master.so';
install plugin rpl_semi_sync_slave soname 'semisync_slave.so';
EOS
}

function dump_sql() {
  mysqldump -uroot --all-databases --single-transaction --triggers --routines --events > /vagrant/fulldump.sql
}

function import_sql() {
  mysql -uroot < /vagrant/fulldump.sql
}

### zabbix
function import_zabbix_data() {
  local zabbix_ver=$(rpm -qa zabbix-server | awk -F\- '{print $3}')
  [[ -n ${zabbix_ver} ]] || return 1
  mysql -uroot zabbix < /usr/share/doc/zabbix-server-mysql-${zabbix_ver}/create/schema/mysql.sql
  mysql -uroot zabbix < /usr/share/doc/zabbix-server-mysql-${zabbix_ver}/create/data/images_mysql.sql
  mysql -uroot zabbix < /usr/share/doc/zabbix-server-mysql-${zabbix_ver}/create/data/data.sql
}

function import_zabbix_data2.2() {
  local zabbix_ver=$(rpm -qa zabbix-server | awk -F\- '{print $3}')
  [[ -n ${zabbix_ver} ]] || return 1
  mysql -uroot zabbix < /usr/share/doc/zabbix-server-mysql-${zabbix_ver}/create/schema.sql
  mysql -uroot zabbix < /usr/share/doc/zabbix-server-mysql-${zabbix_ver}/create/images.sql
  mysql -uroot zabbix < /usr/share/doc/zabbix-server-mysql-${zabbix_ver}/create/data.sql
}

function check_zabbixconf() {
  if [[ -f /etc/zabbix/web/zabbix.conf.php ]]; then
     mv /etc/zabbix/web/zabbix.conf.php /etc/zabbix/web/zabbix.conf.php.`date +%Y%m%d`
  fi
}

function setup_zabbixconf() {
  cp /vagrant/files/zabbix.conf.php /etc/zabbix/web/zabbix.conf.php
}

function setup_zabbix_serverconf() {
  if ! grep -q "DBPassword=zabbix" /etc/zabbix/zabbix_server.conf >/dev/null; then
    echo "DBPassword=zabbix" >> /etc/zabbix/zabbix_server.conf
  fi
}

function setup_timezone() {
  if [[ -f /etc/php.ini ]]; then
    mv /etc/php.ini /etc/php.ini.`date +%Y%m%d`
  fi
  cp /vagrant/files/php.ini /etc/php.ini
}

#function setup_timezone() {
#  comment="# php_value date.timezone Europe\/Riga"
#  if egrep -w -q "${comment}$" /etc/httpd/conf.d/zabbix.conf; then
#    sed -i "s/${comment}$/php_value date.timezone Asia\/Tokyo/g" /etc/httpd/conf.d/zabbix.conf
#  fi
#}

### keepalived
function check_keepalivedconf() {
  if [[ -f /etc/keepalived/keepalived.conf ]]; then
    mv /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.`date +%Y%m%d`
  fi
}

function setup_keepalivedconf() {
  cp /vagrant/files/keepalived.conf /etc/keepalived/keepalived.conf
}

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
    keepalived
    mysql-community-server mysql-community-client
    zabbix-server-mysql zabbix-web-mysql zabbix-web-japanese
"
  if [[ -n "${addpkg}" ]]; then
    yum install -y ${addpkg}
  fi
}
