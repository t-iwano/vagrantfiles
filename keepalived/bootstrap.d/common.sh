#!/bin/bash
#
#
set -e

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

function check_keepalivedconf() {
  if [[ -f /etc/keepalived/keepalived.conf ]]; then
    mv /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.`date +%Y%m%d`
  fi
}

function check_zabbixconf() {
  if [[ -f /etc/zabbix/web/zabbix.conf.php ]]; then
     mv /etc/zabbix/web/zabbix.conf.php /etc/zabbix/web/zabbix.conf.php.`date +%Y%m%d`
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

function import_zabbix_data() {
  local zabbix_ver=$(rpm -qa zabbix-server | awk -F\- '{print $3}')
  [[ -n ${zabbix_ver} ]] || return 1
  mysql -uroot zabbix < /usr/share/doc/zabbix-server-mysql-${zabbix_ver}/create/schema.sql
  mysql -uroot zabbix < /usr/share/doc/zabbix-server-mysql-${zabbix_ver}/create/images.sql
  mysql -uroot zabbix < /usr/share/doc/zabbix-server-mysql-${zabbix_ver}/create/data.sql
}

function setup_zabbixconf() {
  cp /vagrant/config/zabbix.conf.php /etc/zabbix/web/zabbix.conf.php
}

function setup_zabbix_serverconf() {
  if ! grep -q "DBPassword=zabbix" /etc/zabbix/zabbix_server.conf >/dev/null; then
    echo "DBPassword=zabbix" >> /etc/zabbix/zabbix_server.conf
  fi
}

function setup_keepalivedconf() {
  cp /vagrant/config/keepalived.conf /etc/keepalived/keepalived.conf
}

function setup_timezone() {
  comment="# php_value date.timezone Europe\/Riga"
  if egrep -w -q "${comment}$" /etc/httpd/conf.d/zabbix.conf; then
    sed -i "s/${comment}$/php_value date.timezone Asia\/Tokyo/g" /etc/httpd/conf.d/zabbix.conf
  fi
}

function dump_sql() {
  mysqldump -uroot --all-databases --single-transaction --triggers --routines --events > /vagrant/fulldump.sql
}

function import_sql() {
  mysql -uroot < /vagrant/fulldump.sql
}

function install_plugins() {
  mysql -uroot <<EOS
install plugin rpl_semi_sync_master soname 'semisync_master.so';
install plugin rpl_semi_sync_slave soname 'semisync_slave.so';
EOS
}

### service
function start_service() {
  local name=$1
  [[ -n ${name} ]] || return 1
  /etc/init.d/${name} start
}

function restart_service() {
  local name=$1
  [[ -n ${name} ]] || return 1
  /etc/init.d/${name} restart
}
