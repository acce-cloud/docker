#!/bin/sh
# node: eco-p31
# Initializes the swarm, starts swarm visualizer tool.

alias docker='sudo docker'

export MANAGER_IP=172.30.4.62
docker swarm init --advertise-addr $MANAGER_IP
token_worker=`docker swarm join-token --quiet worker`
echo $token_worker

docker network create -d overlay swarm-network
#docker run -it -d -p 8080:8080 -e HOST=$MANAGER_IP -e PORT=8080 -v /var/run/docker.sock:/var/run/docker.sock --name visualizer manomarks/visualizer
