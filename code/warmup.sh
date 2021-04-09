#!/bin/bash

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-9.0/lib64/
export LD_LIBRARY_PATH=/usr/local/cuda-9.0/extras/CUPTI/lib64:$LD_LIBRARY_PATH

t2t-trainer