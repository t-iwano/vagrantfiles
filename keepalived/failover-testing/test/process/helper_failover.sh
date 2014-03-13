#!/bin/bash
#
# requires:
#  bash
#

## include files

## variables

## functions

### failover

function oneTimeSetUp() {
  status_keepalived ${master} | grep -w running || {
    start_keepalived ${master} 
    sleep 30
  }

  status_keepalived ${backup} | grep -w running || {
    start_keepalived ${backup} 
  }
}

function oneTimeTearDown() {
  status_keepalived ${master} | grep -w stopped && {
    start_keepalived ${master}
    sleep 60
  }
}
