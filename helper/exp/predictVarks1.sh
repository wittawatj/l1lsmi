#!/bin/bash

EXPNUM=6
#nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM, 'breastcancer')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'cpuact')" > /dev/null 2> /dev/null &
#nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'diabetes')" > /dev/null 2> /dev/null &
#nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'heart')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'housing')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'image')" > /dev/null 2> /dev/null &
#nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'ionosphere')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'satimage')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'segment')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'vehicle')" > /dev/null 2> /dev/null &
#nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'ctslices')" > /dev/null 2> /dev/null &
#nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'msd')" > /dev/null 2> /dev/null &
nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'senseval2')" > /dev/null 2> /dev/null &
#nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'PCMAC')" > /dev/null 2> /dev/null &
#nohup matlab -nosplash -nodesktop -r "startup();  batchPredictVark( $EXPNUM,  'TOX-171')" > /dev/null 2> /dev/null &

