#!/bin/bash

CLUSTER_NAME=$1
NUM_NODE=$2
EVAL_NAME=$3
#SYNC=$4
WORKDIR=/tmp/workdir
ROOT=ozymandias

# Stop workers
#echo "Terminating worker..."
#for i in $(seq 0 $(( NUM_NODE - 1 ))); do
#    ZONE=`gcloud compute instances list ${CLUSTER_NAME}-worker-${i} --format 'csv[no-heading](zone)'`
#    gcloud compute ssh ${ROOT}@${CLUSTER_NAME}-worker-${i} --zone ${ZONE} -- sudo rm -rf $WORKDIR
#    gcloud compute ssh ${ROOT}@${CLUSTER_NAME}-worker-${i} --zone ${ZONE} -- sudo mkdir -p $WORKDIR
#  #  gcloud compute ssh ${ROOT}@${CLUSTER_NAME}-worker-${i} --zone ${ZONE} -- sudo chmod 777 $WORKDIR
#    gcloud compute scp --zone ${ZONE} \
#      --recurse \
#      warmup.sh \
#      root@${CLUSTER_NAME}-worker-${i}:$WORKDIR
#    gcloud compute ssh ${ROOT}@${CLUSTER_NAME}-worker-${i} --zone ${ZONE} -- $WORKDIR/warmup.sh
#done

#ZONE=`gcloud compute instances list ${EVAL_NAME} --format 'csv[no-heading](zone)'`
#gcloud compute ssh ${ROOT}@${EVAL_NAME} --zone ${ZONE} -- sudo rm -rf $WORKDIR
#gcloud compute ssh ${ROOT}@${EVAL_NAME} --zone ${ZONE} -- sudo mkdir -p $WORKDIR
##  gcloud compute ssh ${ROOT}@${CLUSTER_NAME}-worker-${i} --zone ${ZONE} -- sudo chmod 777 $WORKDIR
#gcloud compute scp --zone ${ZONE} \
#  --recurse \
#  warmup.sh \
#  root@${EVAL_NAME}:$WORKDIR
#gcloud compute ssh ${ROOT}@${EVAL_NAME} --zone ${ZONE} -- $WORKDIR/warmup.sh

SSH="parallel gcloud compute ssh "
SCP="parallel gcloud compute scp "
RECUR=""
NODE_STR=""
ZONE_STR=""
HYPHEN_STR=""
RM_STR=""
MKDIR_STR=""
FILE_NAME=""
ROOT_DIR=""
SCRIPT_STR=""
ZONE=`gcloud compute instances list ${CLUSTER_NAME}-master --format 'csv[no-heading](zone)'`
for i in $(seq 0 ${NUM_NODE}); do
  if [[ ! $i -eq ${NUM_NODE} ]]; then
    NODE_STR+="${ROOT}@${CLUSTER_NAME}-worker-${i} "
    ZONE_STR+="--zone=${ZONE} "
    HYPHEN_STR+="-- "
    MKDIR_STR+="'sudo mkdir -p $WORKDIR' "
    RM_STR+="'sudo rm -rf $WORKDIR' "
    RECUR+="--recurse "
    FILE_NAME+="warmup.sh "
    ROOT_DIR+="root@${CLUSTER_NAME}-worker-${i}:$WORKDIR "
    SCRIPT_STR+="$WORKDIR/warmup.sh "
  else
    NODE_STR+="${ROOT}@${CLUSTER_NAME}-master "
    ZONE_STR+="--zone=${ZONE} "
    HYPHEN_STR+="-- "
    MKDIR_STR+="'sudo mkdir -p $WORKDIR' "
    RM_STR+="'sudo rm -rf $WORKDIR' "
    RECUR+="--recurse "
    FILE_NAME+="warmup.sh "
    ROOT_DIR+="root@${CLUSTER_NAME}-master:$WORKDIR "
    SCRIPT_STR+="$WORKDIR/warmup.sh "
  fi
done

NODE_STR+="${ROOT}@${EVAL_NAME} "
ZONE=`gcloud compute instances list ${EVAL_NAME} --format 'csv[no-heading](zone)'`
ZONE_STR+="--zone=${ZONE} "
HYPHEN_STR+="-- "
MKDIR_STR+="'sudo mkdir -p $WORKDIR' "
RM_STR+="'sudo rm -rf $WORKDIR' "
RECUR+="--recurse "
FILE_NAME+="warmup.sh "
ROOT_DIR+="root@${EVAL_NAME}:$WORKDIR "
SCRIPT_STR+="$WORKDIR/warmup.sh "

CMD=$SSH"::: "$NODE_STR":::+ "$ZONE_STR":::+ "$HYPHEN_STR":::+ "$RM_STR
eval $CMD
CMD=$SSH"::: "$NODE_STR":::+ "$ZONE_STR":::+ "$HYPHEN_STR":::+ "$MKDIR_STR
eval $CMD
CMD=$SCP"::: "$ZONE_STR":::+ "$RECUR":::+ "$FILE_NAME":::+ "$ROOT_DIR
eval $CMD
CMD=$SSH"::: "$NODE_STR":::+ "$ZONE_STR":::+ "$HYPHEN_STR":::+ "$SCRIPT_STR
eval $CMD
#parallel gcloud compute ssh ::: ozymandias@a-master ozymandias@a-worker-0 :::+ --zone=us-west1-b --zone=us-west1-b ::: -- :::+ $WORKDIR/warmup.sh $WORKDIR/warmup.sh

# Stop the master
#echo "Warming up master..."
#ZONE=`gcloud compute instances list ${CLUSTER_NAME}-master --format 'csv[no-heading](zone)'`
#gcloud compute ssh ${ROOT}@${CLUSTER_NAME}-master --zone ${ZONE} -- sudo rm -rf $WORKDIR
#gcloud compute ssh ${ROOT}@${CLUSTER_NAME}-master --zone ${ZONE} -- sudo mkdir -p $WORKDIR
##  gcloud compute ssh ${ROOT}@${CLUSTER_NAME}-worker-${i} --zone ${ZONE} -- sudo chmod 777 $WORKDIR
#gcloud compute scp --zone ${ZONE} \
#  --recurse \
#  warmup.sh \
#  root@${CLUSTER_NAME}-master:$WORKDIR
#gcloud compute ssh ${ROOT}@${CLUSTER_NAME}-master --zone ${ZONE} -- $WORKDIR/warmup.sh
