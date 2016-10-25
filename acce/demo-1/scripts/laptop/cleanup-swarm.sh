#!/bin/sh
# OODT DEMO WITH SWARM MODE
# Script to cleanup the Docker Swarm on the local cluster of VMs

# stop all services
eval $(docker-machine env swarm-manager)
docker service rm wmgr filemgr wmgr-client
docker stop visualizer
docker rm visualizer

# leave the swarm
eval $(docker-machine env swarm-worker1)
docker swarm leave
eval $(docker-machine env swarm-worker2)
docker swarm leave
eval $(docker-machine env swarm-worker3)
docker swarm leave
eval $(docker-machine env swarm-manager)
docker swarm leave --force

# destroy the VMs
docker-machine stop swarm-manager swarm-worker1 swarm-worker2 swarm-worker3
docker-machine rm -y swarm-manager swarm-worker1 swarm-worker2 swarm-worker3
