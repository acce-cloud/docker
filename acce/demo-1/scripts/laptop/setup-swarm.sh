#!/bin/sh
# OODT DEMO WITH SWARM MODE
# Example script to setup a Docker Swarm cluster on a set of local VMs using Swarm Mode

# The swarm is composed of:
# - 1 'swarm-manager' manager node
# - 1 'swarm-worker1' worker node, configured to run a customized OODT file manager
# - 2 'swarm-worker2,3' worker nodes, configured to run a customized OODT workflow manager

# create all VMs
docker-machine create -d virtualbox swarm-manager
docker-machine create -d virtualbox swarm-worker1
docker-machine create -d virtualbox --virtualbox-memory 2048 swarm-worker2
docker-machine create -d virtualbox --virtualbox-memory 2048 swarm-worker3

# start the swarm
eval $(docker-machine env swarm-manager)
export MANAGER_IP=`docker-machine ip swarm-manager`
docker swarm init --advertise-addr $MANAGER_IP
token_worker=`docker swarm join-token --quiet worker`
token_manager=`docker swarm join-token --quiet manager`

# drain the swarm manager to prevent assigment of tasks
docker node update --availability drain swarm-manager

# start swarm visualizer on swarm manager
docker run -it -d -p 5000:5000 -e HOST=$MANAGER_IP -e PORT=5000 --name visualizer -v /var/run/docker.sock:/var/run/docker.sock manomarks/visualizer

# join the swarm
eval $(docker-machine env swarm-worker1)
docker swarm join --token $token_worker $MANAGER_IP:2377

eval $(docker-machine env swarm-worker2)
docker swarm join --token $token_worker $MANAGER_IP:2377

eval $(docker-machine env swarm-worker3)
docker swarm join --token $token_worker $MANAGER_IP:2377

# create overlay network
eval $(docker-machine env swarm-manager)
docker network create -d overlay swarm-network

# assign functional labels to nodes
eval $(docker-machine env swarm-manager)
docker node update --label-add oodt_type=filemgr swarm-worker1
docker node update --label-add oodt_type=wmgr swarm-worker2
docker node update --label-add oodt_type=wmgr swarm-worker3

# initialize directories with shared content under ~/ACCE
mkdir -p ~/ACCE
mkdir -p ~/ACCE/archive
cp -R ../../pges ~/ACCE/.
cp -R ../../workflows ~/ACCE/.
export OODT_ARCHIVE=~/ACCE/archive
export PGE_ROOT=~/ACCE/pges
export OODT_CONFIG=~/ACCE/workflows

# start OODT File Manager on swarm-worker1
eval $(docker-machine env swarm-manager)
docker service create --replicas 1 --name filemgr -p 9000:9000 -p 8983:8983 --network swarm-network  --constraint 'node.labels.oodt_type==filemgr'\
                      --mount type=bind,src=$PGE_ROOT,dst=/usr/local/oodt/pges\
                      --mount type=bind,src=$OODT_CONFIG,dst=/usr/local/oodt/workflows\
                      --mount type=bind,src=$OODT_ARCHIVE,dst=/usr/local/oodt/archive\
                      oodthub/oodt-filemgr

# start OODT Workflow Manager on nodes 2, 3
eval $(docker-machine env swarm-manager)
docker service create --replicas 1 --name wmgr -p 9001:9001 --network swarm-network --constraint 'node.labels.oodt_type==wmgr' -e 'FILEMGR_URL=http://filemgr:9000/'\
                      --mount type=bind,src=$PGE_ROOT,dst=/usr/local/oodt/pges\
                      --mount type=bind,src=$OODT_CONFIG,dst=/usr/local/oodt/workflows\
                      --mount type=bind,src=$OODT_ARCHIVE,dst=/usr/local/oodt/archive\
                      oodthub/oodt-wmgr
docker service scale wmgr=2

# start OODT Worklow Manager client on swarm-worker1
# use the Workflow Manager image with overridden command so not to run another server
eval $(docker-machine env swarm-manager)
docker service create --replicas 1 --name wmgr-client --network swarm-network  --constraint 'node.labels.oodt_type==filemgr' oodthub/oodt-wmgr tail -f /dev/null

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
