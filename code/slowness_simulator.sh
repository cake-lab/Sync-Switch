#!/bin/bash

SLOWNESS=$1
DURATION=$2

sudo tc qdisc add dev ens5 root netem delay ${SLOWNESS}ms

sleep $DURATION

sudo tc qdisc del dev ens5 root netem

#while true; do
#  echo Start slowness
#  sleep 10
#  echo Stop slowness
#  sleep 10
#done

