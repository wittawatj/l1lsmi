#!/bin/bash

EXPNUM=6
#nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM, 'abalone')" > /dev/null 2> /dev/null &
#nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'vowel')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'wine')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'flaresolar')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'german')" > /dev/null 2> /dev/null &
#nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'glass')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'sonar')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'spectf')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'speech')" > /dev/null 2> /dev/null &
#nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'triazines')" > /dev/null 2> /dev/null &
#nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'tic')" > /dev/null 2> /dev/null &
#nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'usps_5000')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'musk1')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'musk2')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'isolet')" > /dev/null 2> /dev/null &
#nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'BASEHOCK')" > /dev/null 2> /dev/null &
#nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'warpPIE10P')" > /dev/null 2> /dev/null &

