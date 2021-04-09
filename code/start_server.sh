#!/bin/bash

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-9.0/lib64/
export LD_LIBRARY_PATH=/usr/local/cuda-9.0/extras/CUPTI/lib64:$LD_LIBRARY_PATH
#cd tensor2tensor
#git pull
#cd ~

WORKDIR=/tmp/workdir

cd $(dirname ${0})
DATADIR=${1}
OUTDIR=${2}
TYPE=${3}
INDEX=${4}
NUM_PS=${5}
NUM_WORKER=${6}
MODEL=${7}
HPARAM_SET=${8}
PROBLEM_DATA=${9}
TRAIN_STEPS=${10}
CKPT=${11}
CLUSTER_NAME=${12}
JOBNAME=${13}
HPARAM=${14}

WORKER_PORT=2222
#echo THIS IS THE NUMBER OF WORKERS $NUM_WORKER
#echo THIS IS THE NUMBER OF PS $NUM_PS


if [ $TYPE -eq 1 ]; then
  ROLE="ps"
elif [ $TYPE -eq 2 ]; then
  ROLE="worker"
  INDEX=$(( INDEX - 1 ))
elif [ $TYPE -eq 3 ]; then
  ROLE="master"
  echo Job name: ${JOBNAME}, SGD: BSP  >> ~/job_log.txt
else
  ROLE="chief"
  echo Job name: ${JOBNAME}, SGD: ASP  >> ~/job_log.txt
fi

export TF_CONFIG=$(sed "s/__INDEX__/$INDEX/;s/__ROLE__/$ROLE/" tf_config.json)
export PYTHONPATH="$PWD":"${PYTHONPATH}"

if [[ $TYPE == 1 ]]; then
#  echo This is a PS
  t2t-trainer --schedule=run_std_server
elif [[ $TYPE == 2 ]]; then
#  echo This is a worker
#  IP=`gcloud compute instances list ${CLUSTER_NAME}-worker-${INDEX} --format 'csv[no-heading](INTERNAL_IP)'`
#  sleep $(( 10 * $INDEX + 40 ))s
  t2t-trainer --master=grpc://${CLUSTER_NAME}-worker-${INDEX}:${WORKER_PORT} --data_dir=${DATADIR} --output_dir=${OUTDIR} --ps_replicas=${NUM_PS} --worker_replicas=$NUM_WORKER --worker_gpu=1 --worker_id=${INDEX} --ps_gpu=0 --schedule=train --worker_job='/job:worker' --model=${MODEL} --hparams_set=${HPARAM_SET} --problem=${PROBLEM_DATA} --train_steps=${TRAIN_STEPS} --save_checkpoints_secs=0 --local_eval_frequency=${CKPT} --hparams=${HPARAM} --worker_gpu_memory_fraction=0.1
elif [[ $TYPE == 3 ]]; then
# This is the sync master
#  IP=`gcloud compute instances list ${CLUSTER_NAME}-master --format 'csv[no-heading](INTERNAL_IP)'`
  t2t-trainer --master=grpc://${CLUSTER_NAME}-master:${WORKER_PORT} --data_dir=${DATADIR} --output_dir=${OUTDIR} --ps_replicas=${NUM_PS} --worker_replicas=1 --worker_gpu=1 --worker_id=${INDEX} --ps_gpu=1 --schedule=train --sync --worker_job='/job:master' --model=${MODEL} --hparams_set=${HPARAM_SET} --problem=${PROBLEM_DATA} --train_steps=${TRAIN_STEPS} --save_checkpoints_secs=0 --local_eval_frequency=${CKPT} --hparams=${HPARAM}
else
# This is the async chief
#  IP=`gcloud compute instances list ${CLUSTER_NAME}-worker-0 --format 'csv[no-heading](INTERNAL_IP)'`
  t2t-trainer --master=grpc://${CLUSTER_NAME}-worker-0:${WORKER_PORT} --data_dir=${DATADIR} --output_dir=${OUTDIR} --ps_replicas=${NUM_PS} --worker_replicas=$NUM_WORKER --worker_gpu=1 --worker_id=${INDEX} --ps_gpu=0 --schedule=train --worker_job='/job:chief' --model=${MODEL} --hparams_set=${HPARAM_SET} --problem=${PROBLEM_DATA} --train_steps=${TRAIN_STEPS} --save_checkpoints_secs=0 --local_eval_frequency=${CKPT} --hparams=${HPARAM} --worker_gpu_memory_fraction=0.1
fi