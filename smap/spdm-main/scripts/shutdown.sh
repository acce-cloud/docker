#!/bin/sh
# Removes the swarm.

#sudo docker service rm spdm-services spdm-stub
#sudo docker service rm spdmserver spdmnode
# remove swarm will stop services too

#---> for node in node1 node2 node3 ...; do
for node in eco-p32 ; do
   ssh ${node} sudo docker swarm leave
done

sudo docker swarm leave --force

sudo docker network ls
