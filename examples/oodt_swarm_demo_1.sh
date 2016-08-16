#!/bin/sh
# OODT SWARM DEMO

# create a VM to hold a consul key-value store, which will be needed to create a network spanning all swarm nodes
#docker-machine create -d virtualbox swarm-keystore
#eval "$(docker-machine env swarm-keystore)"
#docker run -d -p "8500:8500" -h "consul" --name swarm-keystore progrium/consul -server -bootstrap

# download swarm image to local host
# docker pull swarm

# create swarm master
#docker-machine create \
#               -d virtualbox \
#               --swarm --swarm-master \
#               --swarm-discovery="consul://$(docker-machine ip swarm-keystore):8500" \
#               --engine-opt="cluster-store=consul://$(docker-machine ip swarm-keystore):8500" \
#               --engine-opt="cluster-advertise=eth1:2376" \
#               swarm-master

# create swarm workwers, assign label based on services they will host:

#docker-machine create -d virtualbox \
#    --swarm \
#    --swarm-discovery="consul://$(docker-machine ip swarm-keystore):8500" \
#    --engine-opt="cluster-store=consul://$(docker-machine ip swarm-keystore):8500" \
#    --engine-opt="cluster-advertise=eth1:2376" \
#    --engine-label oodt_type=filemgr \
#    swarm-node-01

#docker-machine create -d virtualbox \
#    --swarm \
#    --swarm-discovery="consul://$(docker-machine ip swarm-keystore):8500" \
#    --engine-opt="cluster-store=consul://$(docker-machine ip swarm-keystore):8500" \
#    --engine-opt="cluster-advertise=eth1:2376" \
#    --engine-label oodt_type=wmgr \
#    swarm-node-02

#docker-machine create -d virtualbox \
#    --swarm \
#    --swarm-discovery="consul://$(docker-machine ip swarm-keystore):8500" \
#    --engine-opt="cluster-store=consul://$(docker-machine ip swarm-keystore):8500" \
#    --engine-opt="cluster-advertise=eth1:2376" \
#    --engine-label oodt_type=wmgr \
#    swarm-node-03

# list docker machines
#docker-machine ls

# create overlay network to connect all containers in the swarm
# must connect to any node in the swarm, for example to the swarm master
#eval $(docker-machine env --swarm swarm-master)
#docker network create --driver overlay --subnet=10.0.9.0/24 swarm-network

# list networks available on swarm master
#docker network ls

# run OODT FM container on swarm-node-01:
#docker run -itd --name oodt.filemgr.host -p 8983:8983 -p 9000:9000 -e constraint:oodt_type==filemgr --network=swarm-network oodthub/oodt-filemgr

# run N instances of WM on swrm-node-02,03
#docker pull oodthub/oodt-wmgr
#for i in `seq 1 4`; do docker run -itd --name oodt.wmgr$i.host -P -e constraint:oodt_type==wmgr --network=swarm-network oodthub/oodt-wmgr; done

# list running containers
docker ps
