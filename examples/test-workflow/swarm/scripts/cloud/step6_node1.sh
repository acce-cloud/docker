#!/bin/sh
# node: acce-build1.dyndns.org
# Removes all services from the swarm

docker service rm rabbitmq wmgr filemgr
docker service ls
docker stop visualizer
docker rm visualizer
