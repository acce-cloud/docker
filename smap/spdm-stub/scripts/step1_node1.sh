#!/bin/sh
# node: eco-p31
# Initializes the swarm, starts swarm visualizer tool.
# ip address for eco-p31
export MANAGER_IP=172.30.4.62
sudo docker swarm init --advertise-addr $MANAGER_IP
token_worker=`sudo docker swarm join-token --quiet worker`
echo $token_worker

sudo docker network create -d overlay swarm-network
#sudo docker run -it -d -p 8080:8080 -e HOST=$MANAGER_IP -e PORT=8080 -v /var/run/docker.sock:/var/run/docker.sock --name visualizer manomarks/visualizer
