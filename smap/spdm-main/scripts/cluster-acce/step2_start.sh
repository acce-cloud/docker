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

docker service create --replicas 1 --name spdmserver -p 9000:9000 -p 9001:9001 -p 9002:9002 \
		--network ${SWARM_NETWORK}  --constraint 'node.labels.acce_type==spdm-services'\
		--mount type=bind,src=${SHARED_DIR},dst=/project/spdm \
		oodthub/spdm-services:0.3

#	--hostname spdmserver \

# ---> set --replicas number to create the # of containers
#
docker service create --replicas 2 --name spdmnode -p 9003:9003 \
		--network ${SWARM_NETWORK}  --constraint 'node.labels.acce_stub==true' \
		--mount type=bind,src=${SHARED_DIR},dst=/project/spdm \
		oodthub/spdm-stub:0.3

docker service create --replicas 1 --name orcldb -p 8080:8080 -p 1521:1521 \
		--network ${SWARM_NETWORK} --constraint 'node.labels.acce_type==spdm-services'\
                sath89/oracle-xe-11g
#                --env 'ORACLE_DB_URL=' --env 'ORACLE_ADMIN_URL='\

# use this command to scale instances
#docker service scale spdmstub=2
sleep 20
docker service ls
