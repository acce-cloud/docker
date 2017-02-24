#!/bin/sh
# node: acce-build1.dyndns.org
# Instantiates services on the swarm.
# Note that each service mounts a shared local directory.

docker node update --label-add ecostress_type=head_node acce-build1.dyndns.org
docker node update --label-add ecostress_type=compute_node acce-build2.dyndns.org
docker node update --label-add ecostress_type=compute_node acce-build3.dyndns.org

mkdir -p /usr/local/adeploy/archive

# start RabbitMQ server
docker service create --replicas 1 --name rabbitmq -p 5672:5672 -p 15672:15672 --network swarm-network  --constraint 'node.labels.ecostress_type==head_node'\
                      --env 'RABBITMQ_USER_URL=amqp://oodt-user:changeit@localhost/%2f' --env 'RABBITMQ_ADMIN_URL=http://oodt-admin:changeit@localhost:15672'\
                      oodthub/oodt-rabbitmq

# start file manager on head node
docker service create --replicas 1 --name filemgr -p 9000:9000 -p 8983:8983 --network swarm-network  --constraint 'node.labels.ecostress_type==head_node'\
                      --mount type=bind,src=/usr/local/adeploy/archive,dst=/usr/local/oodt/archive oodthub/ecostress-filemgr

# wait for rabbitmq server to become available
# then start workflow manager on head node
# including rabbitmq consumer for workflow 'ecostress-L3a-workflow'
sleep 5
docker service create --replicas 1 --name wmgr_head_node --network swarm-network --constraint 'node.labels.ecostress_type==head_node'\
                      --mount type=bind,src=/usr/local/adeploy/archive,dst=/usr/local/oodt/archive\
                      --env 'RABBITMQ_USER_URL=amqp://oodt-user:changeit@rabbitmq/%2f' --env 'RABBITMQ_ADMIN_URL=http://oodt-admin:changeit@rabbitmq:15672'\
                      --env 'FILEMGR_URL=http://filemgr:9000/' oodthub/ecostress-wmgr ecostress-L3a-workflow

# start workflow manager on compute nodes
# including rabbitm1 consumers for "ecostress-L3b-workflow", "ecostress-L4-workflow" workflows
docker service create --replicas 1 --name wmgr_compute_node --network swarm-network --constraint 'node.labels.ecostress_type==compute_node'\
                      --mount type=bind,src=/usr/local/adeploy/archive,dst=/usr/local/oodt/archive\
                      --env 'RABBITMQ_USER_URL=amqp://oodt-user:changeit@rabbitmq/%2f' --env 'RABBITMQ_ADMIN_URL=http://oodt-admin:changeit@rabbitmq:15672'\
                      --env 'FILEMGR_URL=http://filemgr:9000/' oodthub/ecostress-wmgr ecostress-L3b-workflow ecostress-L4-workflow

docker service scale wmgr_compute_node=2

docker service ls
docker service ps filemgr
docker service ps wmgr_head_node
docker service ps wmgr_compute_node
docker service ps rabbitmq
