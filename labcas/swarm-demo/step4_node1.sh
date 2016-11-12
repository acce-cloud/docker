#!/bin/sh
# node: acce-build1.dyndns.org
# Instantiates services on the swarm.
# Note that each service mounts shared local directories into standard OODT locations.
# $PGE_ROOT: /usr/local/adeploy/pges --> /usr/local/oodt/pges
# $LABCAS_ARCHIVE: /usr/local/adeploy/archive --> /usr/local/oodt/archive

mkdir -p /usr/local/adeploy/pges
mkdir -p /usr/local/adeploy/archive

docker service create --replicas 1 --name labcas-biomarker-discovery \
                      -p 9000:9000 -p 8983:8983 --network swarm-network \
                      --mount type=bind,src=/usr/local/adeploy/pges,dst=/usr/local/oodt/pges\
                      --mount type=bind,src=/usr/local/adeploy/archive,dst=/usr/local/oodt/archive\
                      oodthub/labcas-biomarker-discovery

docker service scale labcas-biomarker-discovery=3

docker service ls
docker service ps labcas-biomarker-discovery
