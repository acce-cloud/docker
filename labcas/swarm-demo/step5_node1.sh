#!/bin/sh
# node: acce-build1.dyndns.org
# Submits the labcas-biomarker-discovery workflow N times

# identify the container used to execute the wmgr-client
wmgr_client_id=`docker ps | grep labcas-biomarker-discovery | awk '{print $1}'`

# submit the workflow
docker exec -it ${wmgr_client_id} sh -c "cd /usr/local/oodt/cas-workflow/bin; ./wmgr-client --url http://labcas-biomarker-discovery:9001 --operation --sendEvent --eventName biomarker-discovery --metaData --key CrossValidationIterationNumber 3 --key TrainingSet GSE4115_10female_10male.rds"
sleep 5
