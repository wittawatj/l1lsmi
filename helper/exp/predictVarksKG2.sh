#!/bin/bash

EXPNUM=6
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM}, 'abalone')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'vowel')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'wine')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'flaresolar')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'german')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'glass')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'sonar')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'spectf')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'speech')" > /dev/null 2> /dev/null &
#nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'triazines')" > /dev/null 2> /dev/null &
#nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'tic')" > /dev/null 2> /dev/null &
#nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'usps_5000')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'musk1')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'musk2')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'isolet')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'BASEHOCK')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVarkKG( ${EXPNUM},  'warpPIE10P')" > /dev/null 2> /dev/null &

