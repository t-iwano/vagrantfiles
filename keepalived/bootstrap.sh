#!/bin/bash
#
# requires:
# bash
#
set -e
set -x

### params
vagrant_dir=/vagrant
vagrant_repos_dir=${vagrant_dir}/yum.repos.d
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
    mv ${baserepo} ${baserepo}.`date +%Y%m%d`
  fi
}

function change_baserepo() {
  local baserepo=${repos_dir}/${base_repofile}
  local vagrant_baserepo=${vagrant_repos_dir}/${base_repofile}
  if [[ -f "${baserepo}" ]]; then
    mv ${baserepo} ${baserepo}.`date +%Y%m%d`
  fi
  mv ${vagrant_baserepo} ${baserepo}
}

function add_valtrepo() {
  local vaultrepo=${repos_dir}/${vault_repofile}
  local vagrant_vaultrepo=${vagrant_repos_dir}/${vault_repofile}
  if [[ -f "${vaultrepo}" ]]; then
    cp ${vaultrepo} ${vaultrepo}.`date +%Y%m%d`
  fi
  mv ${vagrant_vaultrepo} ${vaultrepo}
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

change_baserepo

yum clean metadata
yum -y update

disabled_ipv6

