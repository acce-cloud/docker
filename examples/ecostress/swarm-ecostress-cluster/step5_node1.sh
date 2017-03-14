#!/bin/sh
# node: eco-p31
# Removes all services from the swarm

alias docker='sudo docker'

docker service rm rabbitmq filemgr wmgr_L3a  wmgr_L3b wmgr_L4
docker service ls
#docker stop visualizer
#docker rm visualizer
