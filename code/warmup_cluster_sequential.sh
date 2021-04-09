#!/bin/bash

CLUSTER_NAME=$1
NUM_NODE=$2
#EVAL_NAME=$3
WORKDIR=/tmp/workdir
ROOT=ozymandias

date

ZONE=`gcloud compute instances list ${CLUSTER_NAME}-master --format 'csv[no-heading](zone)'`

for  i in $(seq 0 $NUM_NODE); do
#    echo "Starting ${CLUSTER_NAME}-worker-${i}..."
    gcloud compute ssh ${ROOT}@$CLUSTER_NAME-worker-${i} --zone ${ZONE} -- sudo rm -rf $WORKDIR
    gcloud compute ssh ${ROOT}@$CLUSTER_NAME-worker-${i} --zone ${ZONE} -- sudo mkdir -p $WORKDIR
    gcloud compute scp --zone ${ZONE} \
      --recurse \
      warmup.sh \
      root@$CLUSTER_NAME-worker-${i}:$WORKDIR
done

for  x in $(seq 0 $NUM_NODE); do
    gcloud compute ssh ${ROOT}@$CLUSTER_NAME-worker-${x} --zone ${ZONE} -- $WORKDIR/warmup.sh &
done

gcloud compute ssh ${ROOT}@${CLUSTER_NAME}-master --zone ${ZONE} -- sudo rm -rf $WORKDIR
gcloud compute ssh ${ROOT}@${CLUSTER_NAME}-master --zone ${ZONE} -- sudo mkdir -p $WORKDIR
#  gcloud compute ssh ${ROOT}@${CLUSTER_NAME}-worker-${i} --zone ${ZONE} -- sudo chmod 777 $WORKDIR
gcloud compute scp --zone ${ZONE} \
  --recurse \
  warmup.sh \
  root@${CLUSTER_NAME}-master:$WORKDIR
gcloud compute ssh ${ROOT}@${CLUSTER_NAME}-master --zone ${ZONE} -- $WORKDIR/warmup.sh

date