#!/bin/sh
# node: eco-p31
# Removes the swarm.

alias docker='sudo docker'

docker node rm eco-p32.tir
docker swarm leave --force
