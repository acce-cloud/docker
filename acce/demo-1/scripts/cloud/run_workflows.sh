#!/bin/sh
# node: acce-build1.dyndns.org
# Script to submit the OODT "test-workflow" N times

wmgr_client_id=`docker ps | grep wmgr-client | awk '{print $1}'`
num_workflows=4

for (( i=1; i<=$num_workflows; i++ )) ; do 
  docker exec -it ${wmgr_client_id} sh -c "cd /usr/local/oodt/cas-workflow/bin; ./wmgr-client --url http://wmgr:9001 --operation --sendEvent --eventName test-workflow --metaData --key Dataset abc --key Project 123 --key Run $i"
  sleep 5
done

#curl "http://${MANAGER_IP}:8983/solr/oodt-fm/select?q=*%3A*&wt=json&indent=true&rows=0"
