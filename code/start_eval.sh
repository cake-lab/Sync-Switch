#!/bin/bash

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-9.0/lib64/
export LD_LIBRARY_PATH=/usr/local/cuda-9.0/extras/CUPTI/lib64:$LD_LIBRARY_PATH

cd $(dirname $0)
OUTDIR=$1
DATADIR=$2
MODEL=$3
HPARAM_SET=$4
PROBLEM=$5

t2t-trainer \
    --worker_job='/job:localhost' \
    --data_dir=${DATADIR} \
    --output_dir=${OUTDIR} \
    --schedule=continuous_eval \
    --model=${MODEL} \
    --problem=${PROBLEM} \
    --hparams_set=${HPARAM_SET}
#    --hparams='is_cifar=True'