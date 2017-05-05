#!/bin/sh
# node: acce-build1.dyndns.org
# Removes all services from the swarm

docker service rm rabbitmq filemgr wmgr_L3a  wmgr_L3b wmgr_L4
docker service ls
docker stop visualizer
docker rm visualizer
