#!/bin/sh
# node: acce-build1.dyndns.org
# Removes the swarm.

docker node rm acce-build3.dyndns.org
docker node rm acce-build2.dyndns.org
docker swarm leave --force
