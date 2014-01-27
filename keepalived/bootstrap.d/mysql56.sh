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
mysql-utilities-1.3.6-1.el6.noarch   http://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-utilities-1.3.6-1.el6.noarch.rpm
EOS
}

## add 3rd party rpm packages
list_3rd_party | while read pkg_name pkg_uri; do
  rpm -qi ${pkg_name} >/dev/null || yum install -y ${pkg_uri}
done

# add rpm packages
addpkgs="
 mysql-community-server mysql-community-client
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


