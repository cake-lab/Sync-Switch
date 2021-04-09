#!/bin/bash

date

CLUSTER_NAME=$1
NUM_NODE=$2
WORKDIR=/tmp/workdir
ROOT=ozymandias

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

#NODE_STR+="${ROOT}@${EVAL_NAME} "
#ZONE=`gcloud compute instances list ${EVAL_NAME} --format 'csv[no-heading](zone)'`
#ZONE_STR+="--zone=${ZONE} "
#HYPHEN_STR+="-- "
#MKDIR_STR+="'sudo mkdir -p $WORKDIR' "
#RM_STR+="'sudo rm -rf $WORKDIR' "
#RECUR+="--recurse "
#FILE_NAME+="warmup.sh "
#ROOT_DIR+="root@${EVAL_NAME}:$WORKDIR "
#SCRIPT_STR+="$WORKDIR/warmup.sh "

CMD=$SSH"::: "$NODE_STR":::+ "$ZONE_STR":::+ "$HYPHEN_STR":::+ "$RM_STR
eval $CMD
CMD=$SSH"::: "$NODE_STR":::+ "$ZONE_STR":::+ "$HYPHEN_STR":::+ "$MKDIR_STR
eval $CMD
CMD=$SCP"::: "$ZONE_STR":::+ "$RECUR":::+ "$FILE_NAME":::+ "$ROOT_DIR
eval $CMD
CMD=$SSH"::: "$NODE_STR":::+ "$ZONE_STR":::+ "$HYPHEN_STR":::+ "$SCRIPT_STR
eval $CMD

date