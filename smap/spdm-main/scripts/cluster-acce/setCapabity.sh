#!/bin/sh
#
if [ -z $1 ] ; then
   echo "Usage: $0 <capacity>
   echo "e.g sh $0 8
   exit
fi
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -r ${SCRIPT_DIR}/env.sh ] ; then
   . ${SCRIPT_DIR}/env.sh
fi
NODE_CAPACITY=$1
docker_spdm_id=`docker ps | grep oodthub/spdm-services | awk '{print $1}'`
NODEIDLIST=(`docker exec -it ${docker_spdm_id} sh -c 'sh $SPDM_HOME/spdm-main/bin/spdm_admin.sh --getNodes' | tail -n +2 | awk '{print $1}'`)

COUNT=${#NODEIDLIST[@]}
#
for ((i=0; i<$COUNT; i++))
do
  docker exec -it --env NODEID=${NODEIDLIST[i]} --env NODE_CAPACITY=${NODE_CAPACITY} ${docker_spdm_id} sh -c 'sh $SPDM_HOME/spdm-main/bin/spdm_admin.sh --setNodeCapacity --nodeId ${NODEID} --capacity ${NODE_CAPACITY}'
done
