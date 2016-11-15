#!/bin/sh
# node: acce-build1.dyndns.org
# Removes all services from the swarm

docker service rm labcas-wmgr labcas-filemgr labcas-wmgr-client
docker service ls
