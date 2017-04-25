#!/bin/sh
#---> modify to your environment
#
#---> MANAGER_IP=[IP address for manager node]
#
MANAGER=eco-p31.tir
MANAGER_IP=172.30.4.62
NODE1=eco-p31.tir
NODE2=eco-p32.tir
SHARED_DIR=/project/dev/clwong/smap/docker-smap

#
# Initializes the swarm, starts swarm visualizer tool.
#
sudo docker swarm init --advertise-addr $MANAGER_IP
token_worker=`sudo docker swarm join-token --quiet worker`
echo $token_worker

sudo docker network create -d overlay swarm-network
sleep 2

#---> for node in ${NODE1} ${NODE2} ${NODE3}... ; do
for node in ${NODE2} ; do
  ssh ${node} sudo docker swarm join --token $token_worker $MANAGER_IP:2377
  sleep 1
done

sudo docker network ls
sudo docker node ls

sudo docker run -it -d -p 8080:8080 -e HOST=$MANAGER_IP -e PORT=8080 -v /var/run/docker.sock:/var/run/docker.sock --name visualizer manomarks/visualizer

#
# Instantiates services on the swarm.
# Note that each service mounts a shared local directory.
sudo docker node update --label-add acce_type=spdm-services ${MANAGER}
#
# ---> add a line for each node
# ---> set acce_stub to true or false to include a node
#
sudo docker node update --label-add acce_stub=false ${NODE1}
sudo docker node update --label-add acce_stub=true ${NODE2}

sudo docker service create --replicas 1 --name spdmserver -p 9000:9000 -p 9001:9001 -p 9002:9002 \
		--network swarm-network  --constraint 'node.labels.acce_type==spdm-services'\
		--mount type=bind,src=${SHARED_DIR},dst=/project/spdm \
		--hostname spdmserver \
		oodthub/spdm-services:0.3


# ---> set --replicas number to create the # of containers
#
sudo docker service create --replicas 2 --name spdmnode \
		--network swarm-network  --constraint 'node.labels.acce_stub==true' \
		--mount type=bind,src=${SHARED_DIR},dst=/project/spdm \
		oodthub/spdm-stub:0.3

# use this command to scale instances
#sudo docker service scale spdmstub=2
sudo docker service ls
