#!/bin/sh
# node: eco-p31.tir
# Instantiates services on the swarm.
# Note that each service mounts a shared local directory.

sudo docker node update --label-add acce_type=spdm-services eco-p31.tir
sudo docker node update --label-add acce_stub=true eco-p31.tir
sudo docker node update --label-add acce_stub=true eco-p32.tir

sudo docker service create --replicas 1 --name spdm-main -p 9000:9000 -p 9001:9001 -p 9002:9002 \
		--network swarm-network  --constraint 'node.labels.acce_type==spdm-services'\
                --mount type=bind,src=/scratch,dst=/scratch oodthub/spdm-services:0.3

sudo docker service create --replicas 1 --name spdm-stub \
		--network swarm-network  --constraint 'node.labels.acce_stub==true'\
                --mount type=bind,src=/scratch,dst=/scratch oodthub/spdm-stub:0.3

sudo docker service scale spdm-stub=2

sudo docker service ls
