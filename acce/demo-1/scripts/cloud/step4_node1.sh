#!/bin/sh
# node: acce-build1.dyndns.org
# Instantiates services on the swarm.
# Note that each service mounts shared local directories into standard OODT locations.

docker node update --label-add oodt_type=filemgr acce-build1.dyndns.org
docker node update --label-add oodt_type=wmgr acce-build2.dyndns.org
docker node update --label-add oodt_type=wmgr acce-build3.dyndns.org

mkdir -p /usr/local/adeploy/archive

docker service create --replicas 1 --name filemgr -p 9000:9000 -p 8983:8983 --network swarm-network  --constraint 'node.labels.oodt_type==filemgr'\
                      --mount type=bind,src=/usr/local/adeploy/pges,dst=/usr/local/oodt/pges\
                      --mount type=bind,src=/usr/local/adeploy/workflows,dst=/usr/local/oodt/workflows\
                      --mount type=bind,src=/usr/local/adeploy/archive,dst=/usr/local/oodt/archive\
                      oodthub/oodt-filemgr

docker service create --replicas 1 --name wmgr -p 9001:9001 --network swarm-network --constraint 'node.labels.oodt_type==wmgr'\
                      --mount type=bind,src=/usr/local/adeploy/pges,dst=/usr/local/oodt/pges\
                      --mount type=bind,src=/usr/local/adeploy/workflows,dst=/usr/local/oodt/workflows\
                      --mount type=bind,src=/usr/local/adeploy/archive,dst=/usr/local/oodt/archive\
                      -e 'FILEMGR_URL=http://filemgr:9000/' oodthub/oodt-wmgr
docker service scale wmgr=2

docker service create --replicas 1 --name wmgr-client --network swarm-network  --constraint 'node.labels.oodt_type==filemgr' oodthub/test-wmgr-client

docker service ls
docker service ps filemgr
docker service ps wmgr
docker service ps wmgr-client
