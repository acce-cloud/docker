#!/bin/sh
# node: acce-build1.dyndns.org
# Instantiates services on the swarm.
# Note that each service mounts a shared local directory.

docker node update --label-add oodt_type=filemgr acce-build1.dyndns.org
docker node update --label-add oodt_type=wmgr acce-build2.dyndns.org
docker node update --label-add oodt_type=wmgr acce-build3.dyndns.org

mkdir -p /usr/local/adeploy/archive

docker service create --replicas 1 --name filemgr -p 9000:9000 -p 8983:8983 --network swarm-network  --constraint 'node.labels.oodt_type==filemgr'\
                      --mount type=bind,src=/usr/local/adeploy/archive,dst=/usr/local/oodt/archive oodthub/test-filemgr

docker service create --replicas 1 --name rabbitmq -p 5672:5672 -p 15672:15672 --network swarm-network  --constraint 'node.labels.oodt_type==filemgr'\
                      --env 'RABBITMQ_USER_URL=amqp://oodt-user:changeit@localhost/%2f' --env 'RABBITMQ_ADMIN_URL=http://oodt-admin:changeit@localhost:15672'\
                      oodthub/oodt-rabbitmq

docker service create --replicas 1 --name wmgr -p 9001:9001 --network swarm-network --constraint 'node.labels.oodt_type==wmgr'\
                      --mount type=bind,src=/usr/local/adeploy/archive,dst=/usr/local/oodt/archive\
                      --env 'RABBITMQ_USER_URL=amqp://oodt-user:changeit@rabbitmq/%2f' --env 'RABBITMQ_ADMIN_URL=http://oodt-admin:changeit@rabbitmq:15672'\
                      --env 'FILEMGR_URL=http://filemgr:9000/' oodthub/test-wmgr
docker service scale wmgr=2

#docker service create --replicas 1 --name wmgr-client --network swarm-network  --constraint 'node.labels.oodt_type==filemgr' oodthub/test-wmgr-client

docker service ls
docker service ps filemgr
docker service ps wmgr
docker service ps rabbitmq
