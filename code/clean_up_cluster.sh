#!/bin/bash

CLUSTER_NAME=$1
NUM_NODE=$2
EVAL_NAME=$3
#SYNC=$4

ROOT=ozymandias
#NUM_PS=$(gcloud compute instances list | grep -E '^ps-[0-9]+ ' | wc -l)
#NUM_WORKER=$(gcloud compute instances list | grep -E '^worker-[0-9]+ ' | wc -l)

#NUM_PS=$(( NUM_PS - 1 ))
#NUM_WORKER=$(( NUM_WORKER - 1 ))

# Stop parameter servers
#echo "Terminating ps..."
#for  i in $(seq 0 ${NUM_NODE}); do
#  echo "Terminating ps-${i}..."
#  ZONE=`gcloud compute instances list ${CLUSTER_NAME}-ps-${i} --format 'csv[no-heading](zone)'`
#  gcloud compute ssh ${ROOT}@${CLUSTER_NAME}-ps-${i} --zone ${ZONE} -- pkill -f t2t-trainer
#done

# Stop workers
#echo "Terminating worker..."
#if [[ ${NUM_NODE} -ge 0 ]]; then
#    for i in $(seq 0 $(( NUM_NODE - 1 ))); do
#      echo "Cleaning up jobs on worker-${i}..."
#      gcloud compute ssh ${ROOT}@${CLUSTER_NAME}-worker-${i} --zone ${ZONE} -- pkill -f t2t-trainer
#    done
#fi

# Stop the master
#echo "Cleaning up jobs on master..."
#if [[ ${SYNC} == 1 ]]; then
#    gcloud compute ssh ${ROOT}@${CLUSTER_NAME}-master --zone ${ZONE} -- pkill -f t2t-trainer
#fi

ZONE=`gcloud compute instances list ${CLUSTER_NAME}-worker-0 --format 'csv[no-heading](zone)'`
SSH="parallel gcloud compute ssh "
NODE_STR=""
ZONE_STR=""
HYPHEN_STR=""
SCRIPT_STR=""
for i in $(seq 0 ${NUM_NODE}); do
  ZONE_STR+="--zone=${ZONE} "
  HYPHEN_STR+="-- "
  SCRIPT_STR+="'pkill -f t2t-trainer' "
  if [[ ! $i -eq ${NUM_NODE} ]]; then
    NODE_STR+="${ROOT}@${CLUSTER_NAME}-worker-${i} "
    ROOT_DIR+="root@${CLUSTER_NAME}-worker-${i}:$WORKDIR "
  else
    NODE_STR+="${ROOT}@${CLUSTER_NAME}-master "
    ROOT_DIR+="root@${CLUSTER_NAME}-master:$WORKDIR "
  fi
done

CMD=$SSH"::: "$NODE_STR":::+ "$ZONE_STR":::+ "$HYPHEN_STR":::+ "$SCRIPT_STR
eval $CMD &

#Stop the evaluator
ZONE=`gcloud compute instances list ${EVAL_NAME} --format 'csv[no-heading](zone)'`
gcloud compute ssh ${ROOT}@${EVAL_NAME} --zone ${ZONE} -- pkill -f t2t-trainer