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
}

##
setup_vars

