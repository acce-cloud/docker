#!/bin/sh
# node: eco-p31.tir
# Removes the swarm.

#sudo docker service rm spdm-services spdm-stub
#sudo docker service rm spdmserver spdmnode
# remove swarm will stop services too
ssh eco-p32 sudo docker swarm leave
sudo docker swarm leave --force

sudo docker network ls
