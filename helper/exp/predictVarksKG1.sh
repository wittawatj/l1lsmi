#!/bin/bash

EXPNUM=6
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM}, 'breastcancer')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'cpuact')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'diabetes')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'heart')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'housing')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'image')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'ionosphere')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'satimage')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'segment')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'vehicle')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'ctslices')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'msd')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'senseval2')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'PCMAC')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'TOX-171')" > /dev/null 2> /dev/null &


