#!/bin/bash

JOBNAME=$1

rm -r /tmp/${JOBNAME}
mkdir /tmp/${JOBNAME}

WORKDIR=/tmp/workdir
ROOT=ozymandias

#touch /tmp/${JOBNAME}/job_start_time.txt
#date -u > /tmp/${JOBNAME}/job_start_time.txt

if [[ $# -lt 1 ]]; then
  PROJECT_ID=$(gcloud config list project --format "value(core.project)")
  BUCKET="gs://${PROJECT_ID}-ml"
else
  BUCKET=$4
fi

pushd $(dirname $0) >/dev/null

# Get the number of nodes
NUM_PS=$2
NUM_WORKER=$3
MODEL=$5
HPARAM_SET=$6
PROBLEM_DATA=$7
TRAIN_STEPS=$8
CKPT=${9}
#AUTOMATION_TEST=${10}
#RUN_NUM=${11}
CLUSTER_NAME=${10}
EVAL_NAME=${11}
DATADIR=${12}
HPARAM=${13}

#NUM_WORKER=$(( NUM_WORKER + 1 ))
#
#NUM_PS=$(( NUM_PS - 1 ))
#NUM_WORKER=$(( NUM_WORKER - 2 ))

PS_PORT=2223
WORKER_PORT=2222
MASTER_INDEX=0
OUTDIR=${BUCKET}/${JOBNAME}

#if [[ $AUTOMATION_TEST == 1 ]]; then
#    OUTDIR=${BUCKET}/${JOBNAME}-run${RUN_NUM}
#else
#    OUTDIR=${BUCKET}/${JOBNAME}
#fi

#case $PROBLEM_DATA in
#    image_cifar10)
#        DATADIR=gs://ml-west/spotTrain/cifar_data
#        ;;
#    image_cifar10_plain)
#        DATADIR=gs://ml-west/spotTrain/cifar_data_plain
#        ;;
#    image_mnist)
#        DATADIR=gs://ml-west/spotTrain/mnist_data
#        ;;
#    image_cifar100)
#        DATADIR=gs://ml-west/spotTrain/cifar100_data
#        ;;
#    *)
#        echo "Data source not found"
#esac

#if [[ $AUTOMATION_TEST == 1 ]]; then
#    JOBNAME=automation
#fi

# Create TF_CONFIG file
ps_entry="\"ps\": ["
for i in $(seq 0 $(( NUM_PS - 1 ))); do
  if [[ ! $i -eq $(( NUM_PS - 1 )) ]]; then
    ps_entry="${ps_entry}\"${CLUSTER_NAME}-worker-${i}:${PS_PORT}\", "
  else
    ps_entry="${ps_entry}\"${CLUSTER_NAME}-worker-${i}:${PS_PORT}\"],"
  fi
done

if [[ $NUM_WORKER -ge 0 ]]; then
    worker_entry="\"worker\": ["
    for i in $(seq 1 $(( NUM_WORKER - 1 ))); do
      if [[ ! $i -eq $(( NUM_WORKER - 1 )) ]]; then
        worker_entry="${worker_entry}\"${CLUSTER_NAME}-worker-${i}:${WORKER_PORT}\", "
      else
        worker_entry="${worker_entry}\"${CLUSTER_NAME}-worker-${i}:${WORKER_PORT}\"],"
      fi
    done
fi

master_entry="\"chief\": [\"${CLUSTER_NAME}-worker-0:${WORKER_PORT}\"]"

cat <<EOF > /tmp/${JOBNAME}/tf_config.json
{
  "environment": "cloud",
  "cluster": {
    ${ps_entry}
    ${worker_entry}
    ${master_entry}
  },
  "task": {
    "index": __INDEX__,
    "type": "__ROLE__"
  }
}
EOF

echo "Start a training job."

ZONE=`gcloud compute instances list ${EVAL_NAME} --format 'csv[no-heading](zone)'`
gcloud compute scp --zone ${ZONE} \
    start_eval.sh \
    root@${EVAL_NAME}:$WORKDIR
gcloud compute ssh ${ROOT}@${EVAL_NAME} --zone ${ZONE} -- $WORKDIR/start_eval.sh $OUTDIR $DATADIR $MODEL $HPARAM_SET $PROBLEM_DATA &

# Copying scripts to nodes
#for i in $(seq 0 $(( NUM_PS - 1 ))); do
#  echo "Starting ${CLUSTER_NAME}-worker-${i}..."
#  ZONE=`gcloud compute instances list ${CLUSTER_NAME}-worker-${i} --format 'csv[no-heading](zone)'`
#  gcloud compute ssh ${ROOT}@${CLUSTER_NAME}-worker-${i} --zone ${ZONE} -- sudo rm -rf $WORKDIR
#  gcloud compute ssh ${ROOT}@${CLUSTER_NAME}-worker-${i} --zone ${ZONE} -- sudo mkdir -p $WORKDIR
##  gcloud compute ssh ${ROOT}@${CLUSTER_NAME}-worker-${i} --zone ${ZONE} -- sudo chmod 777 $WORKDIR
#  gcloud compute scp --zone ${ZONE} \
#    --recurse \
#    /tmp/${JOBNAME}/tf_config.json start_server.sh \
#    root@${CLUSTER_NAME}-worker-${i}:$WORKDIR
#done

ZONE=`gcloud compute instances list ${CLUSTER_NAME}-worker-0 --format 'csv[no-heading](zone)'`
SSH="parallel --jobs 20 gcloud compute ssh "
SCP="parallel --jobs 20 gcloud compute scp "
RECUR=""
NODE_STR=""
ZONE_STR=""
HYPHEN_STR=""
RM_STR=""
MKDIR_STR=""
FILE_NAME=""
FILE_NAME_2=""
ROOT_DIR=""
PS_STR=""
WORKER_STR=""
for i in $(seq 0 $(( NUM_PS-1 )) ); do
  NODE_STR+="${ROOT}@${CLUSTER_NAME}-worker-${i} "
  ZONE_STR+="--zone=${ZONE} "
  HYPHEN_STR+="-- "
  MKDIR_STR+="'sudo mkdir -p $WORKDIR' "
  RM_STR+="'sudo rm -rf $WORKDIR' "
  RECUR+="--recurse "
  FILE_NAME+="/tmp/${JOBNAME}/tf_config.json "
  FILE_NAME_2+="start_server.sh "
  ROOT_DIR+="root@${CLUSTER_NAME}-worker-${i}:$WORKDIR "
  PS_SCRIPT+="'$WORKDIR/start_server.sh $DATADIR $OUTDIR 1 $i $NUM_PS $NUM_WORKER $MODEL $HPARAM_SET $PROBLEM_DATA $TRAIN_STEPS $CKPT ${CLUSTER_NAME} ${JOBNAME} ${HPARAM} ' "
done

CMD=$SSH"::: "$NODE_STR":::+ "$ZONE_STR":::+ "$HYPHEN_STR":::+ "$RM_STR
eval $CMD
CMD=$SSH"::: "$NODE_STR":::+ "$ZONE_STR":::+ "$HYPHEN_STR":::+ "$MKDIR_STR
eval $CMD
CMD=$SCP"::: "$ZONE_STR":::+ "$RECUR":::+ "$FILE_NAME":::+ "$ROOT_DIR
eval $CMD
CMD=$SCP"::: "$ZONE_STR":::+ "$RECUR":::+ "$FILE_NAME_2":::+ "$ROOT_DIR
eval $CMD
CMD=$SSH"::: "$NODE_STR":::+ "$ZONE_STR":::+ "$HYPHEN_STR":::+ "$PS_SCRIPT
eval $CMD &

SSH="parallel --jobs 20 gcloud compute ssh "
#SSH=""
RECUR=""
NODE_STR=""
ZONE_STR=""
HYPHEN_STR=""
RM_STR=""
MKDIR_STR=""
FILE_NAME=""
FILE_NAME_2=""
ROOT_DIR=""
PS_STR=""
WORKER_STR=""
WAIT_STR=""
for i in $(seq 1 $(( NUM_WORKER-1 )) ); do
#  SSH+="gcloud compute ssh "
#  WAIT_STR+="'sleep $(( 5*i )) && ' "
  NODE_STR+="${ROOT}@${CLUSTER_NAME}-worker-${i} "
  ZONE_STR+="--zone=${ZONE} "
  HYPHEN_STR+="-- "
  MKDIR_STR+="'sudo mkdir -p $WORKDIR' "
  RM_STR+="'sudo rm -rf $WORKDIR' "
  RECUR+="--recurse "
  FILE_NAME+="/tmp/${JOBNAME}/tf_config.json "
  FILE_NAME_2+="start_server.sh "
  ROOT_DIR+="root@${CLUSTER_NAME}-worker-${i}:$WORKDIR "
  WORKER_SCRIPT+="'$WORKDIR/start_server.sh $DATADIR $OUTDIR 2 $i $NUM_PS $NUM_WORKER $MODEL $HPARAM_SET $PROBLEM_DATA $TRAIN_STEPS $CKPT ${CLUSTER_NAME} ${JOBNAME} ${HPARAM} ' "
done

CMD=$SSH"::: "$NODE_STR":::+ "$ZONE_STR":::+ "$HYPHEN_STR":::+ "$WORKER_SCRIPT
#CMD="parallel --jobs 20 :::+ "$WAIT_STR":::+ "$SSH":::+ "$NODE_STR":::+ "$ZONE_STR":::+ "$HYPHEN_STR":::+ "$WORKER_SCRIPT
eval $CMD &

# Start parameter servers in the background
#for i in $(seq 0 $(( NUM_PS - 1 ))); do
#  gcloud compute ssh ${ROOT}@${CLUSTER_NAME}-worker-${i} --zone ${ZONE} -- $WORKDIR/start_server.sh $DATADIR $OUTDIR 1 $i $NUM_PS $NUM_WORKER $MODEL $HPARAM_SET $PROBLEM_DATA $TRAIN_STEPS $CKPT ${CLUSTER_NAME} ${JOBNAME} ${HPARAM} &
#done

# Start workers in the background
#if [[ $NUM_WORKER -ge 0 ]]; then
#    for i in $(seq 1 $(( NUM_WORKER - 1 ))); do
#      gcloud compute ssh ${ROOT}@${CLUSTER_NAME}-worker-${i} --zone ${ZONE} -- $WORKDIR/start_server.sh $DATADIR $OUTDIR 2 $i $NUM_PS $NUM_WORKER $MODEL $HPARAM_SET $PROBLEM_DATA $TRAIN_STEPS $CKPT ${CLUSTER_NAME} ${JOBNAME} ${HPARAM} &
#    done
#fi

# Start a master
#echo "Starting chief thread on ${CLUSTER_NAME}-worker-0..."
#ZONE=`gcloud compute instances list ${CLUSTER_NAME}-worker-0 --format 'csv[no-heading](zone)'`
gcloud compute ssh ${ROOT}@${CLUSTER_NAME}-worker-0 --zone ${ZONE} -- $WORKDIR/start_server.sh $DATADIR $OUTDIR 4 $MASTER_INDEX $NUM_PS $NUM_WORKER $MODEL $HPARAM_SET $PROBLEM_DATA $TRAIN_STEPS $CKPT ${CLUSTER_NAME} ${JOBNAME} ${HPARAM}

popd >/dev/null
