#!/bin/sh
# node: eco-p31
# Instantiates services on the swarm.
# Note that each service mounts a shared local directory.

alias docker='sudo docker'

docker node update --label-add ecostress_type=head_node eco-p31.tir
docker node update --label-add ecostress_type=compute_node eco-p32.tir

#mkdir -p /scratch/docker/oodt/archive

# start RabbitMQ server
docker service create --replicas 1 --name rabbitmq -p 5672:5672 -p 15672:15672 --network swarm-network  --constraint 'node.labels.ecostress_type==head_node'\
                      --env 'RABBITMQ_USER_URL=amqp://oodt-user:changeit@localhost/%2f' --env 'RABBITMQ_ADMIN_URL=http://oodt-admin:changeit@localhost:15672'\
                      oodthub/oodt-rabbitmq

# start file manager on head node
docker service create --replicas 1 --name filemgr -p 9000:9000 -p 8983:8983 --network swarm-network  --constraint 'node.labels.ecostress_type==head_node'\
                      --mount type=bind,src=/scratch/oodt/archive,dst=/usr/local/oodt/archive oodthub/ecostress-filemgr

# wait for rabbitmq server to become available
# then start workflow manager on head node
# including rabbitmq consumer for workflow 'ecostress-L3a-workflow'
sleep 5
docker service create --replicas 1 --name wmgr_L3a --network swarm-network --constraint 'node.labels.ecostress_type==head_node'\
                      --mount type=bind,src=/scratch/oodt/archive,dst=/usr/local/oodt/archive\
                      --env 'RABBITMQ_USER_URL=amqp://oodt-user:changeit@rabbitmq/%2f' --env 'RABBITMQ_ADMIN_URL=http://oodt-admin:changeit@rabbitmq:15672'\
                      --env 'FILEMGR_URL=http://filemgr:9000/' oodthub/ecostress-wmgr ecostress-L3a-workflow
docker service scale wmgr_L3a=2

# start workflow managers on compute nodes
# including rabbitmq consumers for "ecostress-L3b-workflow", "ecostress-L4-workflow" workflows
docker service create --replicas 1 --name wmgr_L3b --network swarm-network --constraint 'node.labels.ecostress_type==compute_node'\
                      --mount type=bind,src=/scratch/oodt/archive,dst=/usr/local/oodt/archive\
                      --env 'RABBITMQ_USER_URL=amqp://oodt-user:changeit@rabbitmq/%2f' --env 'RABBITMQ_ADMIN_URL=http://oodt-admin:changeit@rabbitmq:15672'\
                      --env 'FILEMGR_URL=http://filemgr:9000/' oodthub/ecostress-wmgr ecostress-L3b-workflow
docker service scale wmgr_L3b=2

docker service create --replicas 1 --name wmgr_L4 --network swarm-network --constraint 'node.labels.ecostress_type==compute_node'\
                      --mount type=bind,src=/scratch/oodt/archive,dst=/usr/local/oodt/archive\
                      --env 'RABBITMQ_USER_URL=amqp://oodt-user:changeit@rabbitmq/%2f' --env 'RABBITMQ_ADMIN_URL=http://oodt-admin:changeit@rabbitmq:15672'\
                      --env 'FILEMGR_URL=http://filemgr:9000/' oodthub/ecostress-wmgr ecostress-L4-workflow
docker service scale wmgr_L4=2

docker service ls
docker service ps filemgr
docker service ps wmgr_L3a
docker service ps wmgr_L3b
docker service ps wmgr_L4
docker service ps rabbitmq
