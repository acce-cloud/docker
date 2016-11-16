#!/bin/sh
# node: acce-build1.dyndns.org
# Submits the labcas-biomarker-discovery workflow N times

# identify the container used to execute the wmgr-client
wmgr_client_id=`docker ps | grep labcas-wmgr-client | awk '{print $1}'`

# submit NCV workflows
NCV=10
for i in `seq 1 $NCV`
do
  docker exec -it ${wmgr_client_id} sh -c "cd /usr/local/oodt/cas-workflow/bin; ./wmgr-client --url http://labcas-wmgr:9001 --operation --sendEvent --eventName biomarker-discovery --metaData --key CrossValidationIterationNumber $i --key TrainingSet GSE4115_10female_10male.rds"
  sleep 5
done
