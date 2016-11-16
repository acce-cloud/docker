#!/bin/sh
# node: acce-build1.dyndns.org
# Instantiates services on the swarm.
# Note that each service mounts shared local directories into standard OODT locations.
# $PGE_ROOT: /usr/local/adeploy/pges --> /usr/local/oodt/pges
# $LABCAS_ARCHIVE: /usr/local/adeploy/archive --> /usr/local/oodt/archive

mkdir -p /usr/local/adeploy/pges
mkdir -p /usr/local/adeploy/archive

docker node update --label-add oodt_type=filemgr acce-build1.dyndns.org
docker node update --label-add oodt_type=wmgr acce-build2.dyndns.org
docker node update --label-add oodt_type=wmgr acce-build3.dyndns.org

# start services: same image, different applications
docker service create --replicas 1 --name labcas-wmgr \
                      -p 9001:9001 --network swarm-network \
                      --mount type=bind,src=/usr/local/adeploy/pges,dst=/usr/local/oodt/pges \
                      --mount type=bind,src=/usr/local/adeploy/archive,dst=/usr/local/oodt/archive \
                      --env FILEMGR_URL=http://labcas-filemgr:9000 \
                      --constraint 'node.labels.oodt_type==wmgr' \
                      oodthub/labcas-biomarker-discovery \
                      /usr/bin/supervisord -c /etc/supervisor/supervisord-workflow.conf

docker service create --replicas 1 --name labcas-filemgr \
                      --mount type=bind,src=/usr/local/adeploy/archive,dst=/usr/local/oodt/archive \
                      --constraint 'node.labels.oodt_type==filemgr' \
                      --network swarm-network \
                      -p 9000:9000 -p 8983:8983 \
                      oodthub/labcas-biomarker-discovery \
                      /usr/bin/supervisord -c /etc/supervisor/supervisord-filemgr.conf

docker service create --replicas 1 --name labcas-wmgr-client \
                      --network swarm-network \
                      --env WORKFLOW_URL=http://labcas-wmgr:9000 \
                      --constraint 'node.labels.oodt_type==filemgr' \
                      oodthub/labcas-biomarker-discovery \
                      tail -f /dev/null

docker service scale labcas-wmgr=4

docker service ls
docker service ps labcas-wmgr
docker service ps labcas-filemgr
docker service ps labcas-wmgr-client
