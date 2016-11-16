#!/bin/sh
# Script that submits N iterations of the biomarker discovery stock pipeline.
# Processing is executed by the container "labcas-biomarker-discovery" on the current host.
# Currently, all iterations are executed in parallel.
#
# Usage: ./run_stock_pipeline.sh N

# identify the container used to execute the wmgr-client
wmgr_client_id=`docker ps | grep labcas-biomarker-discovery | awk '{print $1}'`

# submit NCV workflows
NCV=$1
for i in `seq 1 $NCV`
do
  docker exec -it ${wmgr_client_id} sh -c "cd /usr/local/oodt/cas-workflow/bin; ./wmgr-client --url http://localhost:9001 --operation --sendEvent --eventName biomarker-discovery --metaData --key CrossValidationIterationNumber $i --key TrainingSet GSE4115_10female_10male.rds"
  sleep 5
done
