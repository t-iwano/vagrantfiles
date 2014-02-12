#!/bin/bash
#
# requires:
# bash
#
set -e
set -x

#### params
vagrant_dir=/vagrant
repos_dir=/etc/yum.repos.d
base_repofile=CentOS-Base.repo
vault_repofile=CentOS-Vault-6.4.repo

### function
function yum() {
  $(type -P yum) "${@}"
}

function disabled_baserepo() {
  local baserepo=${repos_dir}/${base_repofile}
  if [[ -f "${baserepo}" ]]; then
    mv ${baserepo} ${baserepo}.back
  fi
}

function add_valtrepo() {
  local vaultrepo=${vagrant_dir}/${vault_repofile}
  if [[ -f "${vaultrepo}" ]]; then
    cp ${vaultrepo} ${repos_dir}/${vault_repofile}
  fi
}

function disabled_ipv6() {
  if ! grep -q "NETWORKING_IPV6" /etc/sysconfig/network >/dev/null; then
    echo "NETWORKING_IPV6=no" >> /etc/sysconfig/network
  fi
  [[ -f /etc/modprobe.d/disable-ipv6.conf ]] || {
    echo "options ipv6 disable=1" > /etc/modprobe.d/disable-ipv6.conf
  }
  chkconfig ip6tables off
}

### base package update
disabled_baserepo
add_valtrepo
yum clean metadata
yum -y update

disabled_ipv6

