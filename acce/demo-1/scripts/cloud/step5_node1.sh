#!/bin/sh
# node: acce-build1.dyndns.org
# Submits the OODT "test-workflow" (twice), then queries the Solr catalog

wmgr_client_id=`docker ps | grep wmgr-client | awk '{print $1}'`

docker exec -it ${wmgr_client_id} sh -c "cd /usr/local/oodt/cas-workflow/bin; ./wmgr-client --url http://wmgr:9001 --operation --sendEvent --eventName test-workflow --metaData --key Dataset abc --key Project 123 --key Run 1"
sleep 5

docker exec -it ${wmgr_client_id} sh -c "cd /usr/local/oodt/cas-workflow/bin; ./wmgr-client --url http://wmgr:9001 --operation --sendEvent --eventName test-workflow --metaData --key Dataset abc --key Project 123 --key Run 2"
sleep 5

curl "http://${MANAGER_IP}:8983/solr/oodt-fm/select?q=*%3A*&wt=json&indent=true&rows=0"
