#!/bin/sh
# OODT DEMO WITH SWARM MODE
# Script that submits the "test-workflow" on the Docker Swarm

# start the swarm
eval $(docker-machine env swarm-manager)
export MANAGER_IP=`docker-machine ip swarm-manager`

# execute test-workflow (twice)
eval $(docker-machine env swarm-worker1)
wmgr_client_id=`docker ps | grep wmgr-client | awk '{print $1}'`
docker exec -it ${wmgr_client_id} sh -c "cd /usr/local/oodt/cas-workflow/bin; ./wmgr-client --url http://wmgr:9001 --operation --sendEvent --eventName test-workflow --metaData --key Dataset abc --key Project 123 --key Run 1"
sleep 5
docker exec -it ${wmgr_client_id} sh -c "cd /usr/local/oodt/cas-workflow/bin; ./wmgr-client --url http://wmgr:9001 --operation --sendEvent --eventName test-workflow --metaData --key Dataset abc --key Project 123 --key Run 2"
sleep 5

# query Solr
eval $(docker-machine env swarm-manager)
wget -O select.json "http://${MANAGER_IP}:8983/solr/oodt-fm/select?q=*%3A*&wt=json&indent=true&rows=0" 
