#!/bin/sh
#
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -r ${SCRIPT_DIR}/env.sh ] ; then
   . ${SCRIPT_DIR}/env.sh
fi
#
# restart service spdmserver
#
docker service rm ${SPDM_HOST}
#
# ---> set SPDMNODE_01=<containerId>, SPDMNODE_02=<containerId>
#
SPDMNODE_01=localhost
SPDMNODE_02=localhost
docker service create --replicas 1 --name ${SPDM_HOST} -p 9000:9000 -p 9001:9001 -p 9002:9002 \
		--network ${SWARM_NETWORK}  --constraint 'node.labels.acce_type==spdm-services'\
		--mount type=bind,src=${SHARED_DIR},dst=/project/spdm \
		--env DB_HOST=${DB_HOST} --env DB_PORT=${DB_PORT} \
		--env DB_INSTANT=${DB_INSTANT} --env DB_DOMAIN=${DB_DOMAIN} \
		--env DB_USER=${DB_USER} --env DB_PASS=${DB_PASS} \
		--env FILEMGR_URL=http://${SPDM_HOST}:9000 \
		--env WORKFLOW_URL=http://${SPDM_HOST}:9001 \
		--env RESMGR_URL=http://${SPDM_HOST}:9002 \
		--env SPDMNODE_01=${SPDMNODE_01} \
		--env SPDMNODE_02=${SPDMNODE_02} \
		oodthub/spdm-services:0.3

sleep 60
docker service ls
docker ps -a
