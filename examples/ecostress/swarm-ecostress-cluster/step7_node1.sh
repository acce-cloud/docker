#!/bin/sh
# node: eco-p31
# Removes the swarm.

docker node rm eco-p32.tir
docker swarm leave --force
