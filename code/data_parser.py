from datetime import datetime as dt
import codecs
import re
import csv
import numpy as np
import pandas as pd

def timeConvert(s):
    # return dt.strptime(s, '%Y-%m-%d %H:%M:%S.%f')
    return (dt.strptime(s, '%Y-%m-%d %H:%M:%S.%f') - dt(1970, 1, 1)).total_seconds()

def convertLoss(filename, last_step, last_loss, last_time, switch_time, switch_step):
    time = timeConvert(last_time)
    time_overhead = timeConvert(switch_time)
    data = pd.read_csv(filename)
    data.loc[len(data['Wall time'])] = {'Wall time': time, 'Step': last_step, 'Value':last_loss}
    temp = []
    diff = 0
    for i in range(len(data['Wall time'])):
        if data['Step'][i] == switch_step+1:
            diff = data['Wall time'][i] - time_overhead
        if data['Step'][i] > switch_step:
            data['Wall time'][i] -= diff
        temp.append(data['Wall time'][i] - data['Wall time'][0])
    data.insert(2,"Time",temp,True)
    data.to_csv('/Users/ozymandias/desktop/loss_proc.csv', index=False)

def convertAcc(filename, switch_step):
    data = pd.read_csv(filename)
    temp = []
    for i in range(len(data['Wall time'])):
        if data['Step'][i] == switch_step:
            diff = data['Wall time'][i+1] - data['Wall time'][i]
            data = data.drop([i+1])
            break
    for i in range(len(data['Wall time'])+1):
        try:
            if data['Step'][i] > switch_step:
                data['Wall time'][i] -= diff
            temp.append(data['Wall time'][i] - data['Wall time'][0])
        except:
            pass
    data.insert(2, "Time", temp, True)
    data.to_csv('/Users/ozymandias/desktop/acc_proc.csv', index=False)

# print timeConvert('2020-10-21 15:01:08.834442')

## switch_time: end time for BSP portion
end_time = '2020-10-22 05:00:31.083884'
switch_time = '2020-10-22 04:32:13.294212'
file = "/Users/ozymandias/desktop/cornu_data/straggler_new/policy2_freq4_2straggler_30ms_run1/loss.csv"
file_2 = "/Users/ozymandias/desktop/cornu_data/straggler_new/policy2_freq4_2straggler_30ms_run1/acc.csv"
convertLoss(file, 61213, 0.01154697, end_time, switch_time, 400)
convertAcc(file_2, 400)