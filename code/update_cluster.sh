#!/bin/bash

CLUSTER_NAME=$1
NUM_NODE=$2
#SYNC=$3

ROOT=ozymandias

# Stop workers
#echo "Terminating worker..."
if [[ ${NUM_NODE} -ge 0 ]]; then
    for i in $(seq 0 $(( NUM_NODE - 1 ))); do
      echo "Cleaning up jobs on worker-${i}..."
      ZONE=`gcloud compute instances list ${CLUSTER_NAME}-worker-${i} --format 'csv[no-heading](zone)'`
      gcloud compute ssh ${ROOT}@${CLUSTER_NAME}-worker-${i} --zone ${ZONE} -- sudo apt-get update | sudo apt-get upgrade -y
    done
fi

# Stop the master
echo "Cleaning up jobs on master..."
#if [[ ${SYNC} == 1 ]]; then
ZONE=`gcloud compute instances list ${CLUSTER_NAME}-master --format 'csv[no-heading](zone)'`
gcloud compute ssh ${ROOT}@${CLUSTER_NAME}-master --zone ${ZONE} -- sudo apt-get update | sudo apt-get upgrade -y
#fi