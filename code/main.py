import os
import argparse
import sys
import subprocess
import time
import googleapiclient.discovery
import googleapiclient
import threading
import paramiko

PROJECTNAME = "shijian-18"
if os.path.exists('/Users/ozymandias/Desktop/cloudComputing/shijian-18-key.json'):
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = '/Users/ozymandias/Desktop/cloudComputing/shijian-18-key.json'
COMPUTE = googleapiclient.discovery.build('compute', 'v1')

def main(job_name, num_ps, num_worker, bucket_dir, model, hparam_set, problem, train_steps, ckpt_frequency, cluster_name, eval_name, switch_order, data_dir, hparams):
    sleep_time = 90
    for i in range(len(switch_order)):
        if switch_order[i] == '1':
            subprocess.call(
                ["./bsp.sh", job_name, num_ps, num_worker, bucket_dir, model, hparam_set,
                 problem, train_steps[i], ckpt_frequency[i], cluster_name, eval_name, data_dir, hparams[i]])
        else:
            subprocess.call(
                ["./asp.sh", job_name, num_ps, num_worker, bucket_dir, model, hparam_set,
                 problem, train_steps[i], ckpt_frequency[i], cluster_name, eval_name, data_dir, hparams[i]])
        for j in range(sleep_time):
            time.sleep(1)
            print("Waiting to clean up cluster: " + str(sleep_time-j))
        subprocess.call(
            ["./clean_up_cluster.sh", cluster_name, num_worker, eval_name, switch_order[i]])
    print "Job done."

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--job-name',
        type=str,
        required=True,
        help='The name for your deep learning job.')
    parser.add_argument(
        '--num-ps',
        type=str,
        required=True,
        help='Number of parameter servers to be used for training.')
    parser.add_argument(
        '--num-worker',
        type=str,
        required=True,
        help='Number of workers to be used for training.')
    parser.add_argument(
        '--bucket-dir',
        type=str,
        required=True,
        default="gs://shijian-18-ml",
        help='Source bucket of external storage.')
    parser.add_argument(
        '--model',
        type=str,
        required=True,
        help='Deep neural network to be trained.')
    parser.add_argument(
        '--hparam-set',
        type=str,
        required=True,
        help='Hyperparameter for the model.')
    parser.add_argument(
        '--problem',
        type=str,
        required=True,
        help='Problem dataset to be trained on.')
    parser.add_argument(
        '--train-steps',
        type=str, nargs='*',
        required=True,
        help='How many steps to train the model.')
    parser.add_argument(
        '--ckpt-frequency',
        type=str, nargs='*',
        required=True,
        help='How frequent to dump checkpoint files.')
    parser.add_argument(
        '--cluster-name',
        type=str,
        required=True,
        help='The prefix for the training cluster.')
    parser.add_argument(
        '--eval-name',
        type=str,
        required=True,
        help='The name for the evaluator.')
    parser.add_argument(
        '--switch-order',
        type=str,
        required=True,
        help='The order of SGD applied.')
    parser.add_argument(
        '--data-dir',
        type=str,
        required=True,
        help='The directory where the input data is stored.')
    parser.add_argument(
        '--hparams',
        type=str, nargs='*',
        required=False,
        help='Modified hyperparameters.')
    # parser.add_argument(
    #     '--job-dir',
    #     type=str,
    #     required=True,
    #     help='The directory where the model will be stored.')
    args = parser.parse_args()

    main(**vars(args))