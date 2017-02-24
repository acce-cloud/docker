#!/bin/sh
# node: acce-build1.dyndns.org
# Removes all services from the swarm

docker service rm rabbitmq filemgr wmgr_compute_node wmgr_head_node
docker service ls
docker stop visualizer
docker rm visualizer
