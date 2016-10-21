#!/bin/sh
# node: acce-build1.dyndns.org
# Instantiates services on the swarm

docker node update --label-add oodt_type=filemgr acce-build1.dyndns.org
docker node update --label-add oodt_type=wmgr acce-build2.dyndns.org
docker node update --label-add oodt_type=wmgr acce-build3.dyndns.org

docker service create --replicas 1 --name filemgr -p 9000:9000 -p 8983:8983 --network swarm-network  --constraint 'node.labels.oodt_type==filemgr' oodthub/test-filemgr

docker service create --replicas 1 --name wmgr -p 9001:9001 --network swarm-network --constraint 'node.labels.oodt_type==wmgr' -e 'FILEMGR_URL=http://filemgr:9000/' oodthub/test-wmgr
docker service scale wmgr=2

docker service create --replicas 1 --name wmgr-client --network swarm-network  --constraint 'node.labels.oodt_type==filemgr' oodthub/test-wmgr-client

docker service ls
docker service ps filemgr
docker service ps wmgr
docker service ps wmgr-client
