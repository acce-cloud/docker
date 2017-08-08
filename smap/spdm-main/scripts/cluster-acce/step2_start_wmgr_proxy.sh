#!/bin/sh
#
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -r ${SCRIPT_DIR}/env.sh ] ; then
   . ${SCRIPT_DIR}/env.sh
fi
#
# Instantiates services on the swarm.
# Note that each service mounts a shared local directory.
docker node update --label-add acce_type=spdm-services ${MANAGER}
#
# ---> add a line for each node
# ---> set acce_stub to true or false to include a node
#
docker node update --label-add acce_stub=false ${MANAGER}
docker node update --label-add acce_stub=true ${NODE1}
docker node update --label-add acce_stub=true ${NODE2}

docker service create --replicas 1 --name orcldb -p 8080:8080 -p 1521:1521 \
                --network ${SWARM_NETWORK} --constraint 'node.labels.acce_type==spdm-services'\
                sath89/oracle-xe-11g

# ---> set --replicas number to create the # of containers
#
docker service create --replicas 1 --name spdmnode -p 9002:9002 \
                --network ${SWARM_NETWORK}  --constraint 'node.labels.acce_stub==true' \
                --mount type=bind,src=${SHARED_DIR},dst=/project/spdm \
                --env DB_HOST=${DB_HOST} --env DB_PORT=${DB_PORT} \
                --env DB_INSTANT=${DB_INSTANT} --env DB_DOMAIN=${DB_DOMAIN} \
                --env DB_USER=${DB_USER} --env DB_PASS=${DB_PASS} \
                --env FILEMGR_URL=http://${SPDM_HOST}:9000 \
                --env WORKFLOW_URL=http://spdmnode:9001 \
                --env PGE_WORKFLOW_URL=http://localhost:9001 \
                --env RESOURCEMGR_URL= \
                --env SPDM_COMPONENTS="workflow" \
                oodthub/spdm-services:0.3
sleep 60

docker service create --replicas 1 --name ${SPDM_HOST} -p 9000:9000 -p 8080:8080 -p 9080:9080 \
                --network ${SWARM_NETWORK}  --constraint 'node.labels.acce_type==spdm-services'\
                --mount type=bind,src=${SHARED_DIR},dst=/project/spdm \
                --env DB_HOST=${DB_HOST} --env DB_PORT=${DB_PORT} \
                --env DB_INSTANT=${DB_INSTANT} --env DB_DOMAIN=${DB_DOMAIN} \
                --env DB_USER=${DB_USER} --env DB_PASS=${DB_PASS} \
                --env FILEMGR_URL=http://${SPDM_HOST}:9000 \
                --env SPDM_COMPONENTS="filemgr all-crawler" \
                oodthub/spdm-services:0.3

# use this command to scale instances
#docker service scale spdmnode=3

sleep 60
