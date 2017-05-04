#!/bin/sh
#
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -r ${SCRIPT_DIR}/env.sh ] ; then
   . ${SCRIPT_DIR}/env.sh
fi
#
# stop db container
#
docker service rm orcldb
# start db container
docker service create --replicas 1 --name orcldb -p 8080:8080 -p 1521:1521 \
		--network ${SWARM_NETWORK} --constraint 'node.labels.acce_type==spdm-services'\
                sath89/oracle-xe-11g
sleep 15 
docker service ls
