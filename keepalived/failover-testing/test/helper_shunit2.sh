# -*-Shell-script-*-
#
# requires:
#   bash
#

## system variables

readonly shunit2_file=${BASH_SOURCE[0]%/*}/shunit2

## include files

. ${BASH_SOURCE[0]%/*}/functions.sh

## environment-specific configuration

[[ -f ${BASH_SOURCE[0]%/*}/failover ]] && { . ${BASH_SOURCE[0]%/*}/failover; } || :

## group variables

## group functions

function setup_vars() {
  MASTER_HOST=${MASTER_HOST:-keepalived01}
  BACKUP_HOST=${BACKUP_HOST:-keepalived02}
  PUBLIC_INTERFACE=${PUBLIC_INTERFACE:-eth1}
  WAKAME_INTERFACE=${WAKAME_INTERFACE:-eth2}
}

##
setup_vars

