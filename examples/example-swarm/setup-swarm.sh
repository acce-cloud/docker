#!/bin/sh
# OODT SWARM DEMO
# Example script to setup a Docker Swaem cluster on a set of local VMs created with Docker Machine

# The swarm is composed of:
# - 'swarm-keystore' node running a consul key/value service
# - 'swarm-master' node
# - 3 'swarm-node-oX' worker nodes, configured to run an OODT file manager or an OODT workflow manager

# create a VM to hold a consul key-value store, which will be needed to create a network spanning all swarm nodes
echo "\nCREATING SWARM DISCOVERY SERVICE: 'swarm-keystore'"
docker-machine create -d virtualbox swarm-keystore
eval "$(docker-machine env swarm-keystore)"
docker run -d -p "8500:8500" -h "consul" --name swarm-keystore progrium/consul -server -bootstrap

# download swarm image to local host
docker pull swarm

# create swarm master
echo "\nCREATING SWARM MASTER NODE: 'swarm-master'"
docker-machine create \
               -d virtualbox \
               --swarm --swarm-master \
               --swarm-discovery="consul://$(docker-machine ip swarm-keystore):8500" \
               --engine-opt="cluster-store=consul://$(docker-machine ip swarm-keystore):8500" \
               --engine-opt="cluster-advertise=eth1:2376" \
               swarm-master

# create swarm workwers, assign label based on services they will host:
# use more memory for workers
echo "\nCREATING SWARM WORKER NODE: 'swarm-node-01'"
docker-machine create -d virtualbox --virtualbox-memory 4096 \
    --swarm \
    --swarm-discovery="consul://$(docker-machine ip swarm-keystore):8500" \
    --engine-opt="cluster-store=consul://$(docker-machine ip swarm-keystore):8500" \
    --engine-opt="cluster-advertise=eth1:2376" \
    --engine-label oodt_type=filemgr \
    swarm-node-01
echo "\nCREATING SWARM WORKER NODE: 'swarm-node-02'"
docker-machine create -d virtualbox --virtualbox-memory 4096 \
    --swarm \
    --swarm-discovery="consul://$(docker-machine ip swarm-keystore):8500" \
    --engine-opt="cluster-store=consul://$(docker-machine ip swarm-keystore):8500" \
    --engine-opt="cluster-advertise=eth1:2376" \
    --engine-label oodt_type=wmgr \
    swarm-node-02
echo "\nCREATING SWARM WORKER NODE: 'swarm-node-03'"
docker-machine create -d virtualbox --virtualbox-memory 4096 \
    --swarm \
    --swarm-discovery="consul://$(docker-machine ip swarm-keystore):8500" \
    --engine-opt="cluster-store=consul://$(docker-machine ip swarm-keystore):8500" \
    --engine-opt="cluster-advertise=eth1:2376" \
    --engine-label oodt_type=wmgr \
    swarm-node-03

# list docker machines
docker-machine ls

# create overlay network to connect all containers in the swarm
# may connect to any node in the swarm, for example to the swarm master
# the network will span all nodes in the swarm
echo "\nCREATING OVERLAY NETWORK: 'swarm-network'"
eval $(docker-machine env --swarm swarm-master)
docker network create --driver overlay --subnet=10.0.9.0/24 swarm-network

# list networks available on swarm master
docker network ls

# download OODT FM container on swarm-node-01:
eval "$(docker-machine env swarm-node-01)"
docker pull oodthub/oodt-filemgr

#echo "\nRUNNING OODT FILE MANAGER CONTAINER: 'oodthub/oodt-filemgr' ON SWARM NODE: 'swarm-node-01'"
#docker run -itd --name oodt.filemgr.host -p 8983:8983 -p 9000:9000 -e constraint:oodt_type==filemgr --network=swarm-network oodthub/oodt-filemgr

# download OODT WM onto swarm-node-02,03
eval "$(docker-machine env swarm-node-02)"
docker pull oodthub/oodt-wmgr
docker pull oodthub/oodt-example-swarm 
eval "$(docker-machine env swarm-node-03)"
docker pull oodthub/oodt-wmgr
docker pull oodthub/oodt-example-swarm 

# run N instances of WM + test-workflow on swarm-node-02,03
#echo "\nRUNNING MULTIPLE OODT WORKFLOW MANAGER CONTAINERS: 'oodt-example-swarm' ON SWARM NODES: swarm-node-02,03"
#docker pull oodthub/oodt-example-swarm
#for i in `seq 1 4`; do docker run -itd --name oodt.wmgr$i.host -P -e constraint:oodt_type==wmgr --network=swarm-network oodthub/oodt-example-swarm; done

# list running containers
docker ps

# cleanup
#echo "\nSTOPPING AND REMOVING ALL OODT CONTAINERS AND DOCKER MACHINES"
#docker-machine stop swarm-node-03 swarm-node-02 swarm-node-01 swarm-master swarm-keystore
#docker-machine rm -f swarm-node-03 swarm-node-02 swarm-node-01 swarm-master swarm-keystore
