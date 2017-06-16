#!/bin/sh
# This script is to scale up spdmnode service and update Resource Manager policy accordingly
#
if [ -z $1 ] ; then
   echo "Usage: $0 <replicas>
   echo "e.g sh $0 8
   exit
fi
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -r ${SCRIPT_DIR}/env.sh ] ; then
   . ${SCRIPT_DIR}/env.sh
fi
docker service scale spdmnode=$1
docker_spdm_id=`docker ps | grep oodthub/spdm-services | awk '{print $1}'`
#
NODEIDLIST=(`docker exec -it ${docker_spdm_id} sh -c 'sh $SPDM_HOME/spdm-main/bin/spdm_admin.sh --getNodes' | tail -n +2 | awk '{print $1}'`)
URLLIST=`docker exec -it ${docker_spdm_id} sh -c 'sh $SPDM_HOME/spdm-main/bin/spdm_admin.sh --getNodes' | tail -n +2 | awk '{print $3}'`
IDS=(`docker service ps spdmnode | tail -n +2 | awk '{print $1}'`)
NAMES=(`docker service ps spdmnode | tail -n +2 | awk '{print $2}'`)
#
# Add new nodes
#
COUNT=${#IDS[@]}
#
echo "Current RM configuration contains:"
echo ${URLLIST}
echo "Adding new nodes....."
for ((i=0; i<$COUNT; i++))
do
  IP=`docker inspect -f "{{range .NetworksAttachments}}{{if eq .Network.Spec.Name \"${SWARM_NETWORK}\"}}{{index .Addresses 0}}{{end}}{{end}}" ${IDS[i]} |  cut -d "/" -f1`
  if [[ ! ${URLLIST} == *"${IP}"* ]]; then
      echo "${NAMES[i]} ${IP} not exists"
      docker exec -it --env CLONE=${NODEIDLIST[0]} --env NODEID=${NAMES[i]} --env IP_ADDR=http://${IP}:9003 ${docker_spdm_id} sh -c 'sh $SPDM_HOME/spdm-main/bin/spdm_admin.sh --cloneNode --existingNodeId $CLONE --nodeId $NODEID --ipAddr $IP_ADDR'
  fi
done
#
# Remove old nodes
#
IPLIST=(`docker inspect -f "{{range .NetworksAttachments}}{{if eq .Network.Spec.Name \"${SWARM_NETWORK}\"}}{{index .Addresses 0}}{{end}}{{end}}" $(docker service ps -q spdmnode) |  cut -d "/" -f1`)
NODEIDS=(`docker exec -it ${docker_spdm_id} sh -c 'sh $SPDM_HOME/spdm-main/bin/spdm_admin.sh --getNodes' | tail -n +2 | awk '{print $1}'`)
URLS=(`docker exec -it ${docker_spdm_id} sh -c 'sh $SPDM_HOME/spdm-main/bin/spdm_admin.sh --getNodes' | tail -n +2 | awk '{print $3}'`)
COUNT=${#NODEIDS[@]}
#
echo "Current docker service tasks:"
echo ${IPLIST[@]}
echo "Cleaning up nodes no longer used....."
for ((i=0; i<$COUNT; i++))
do
  IP=`echo ${URLS[i]} | sed -e "s/[^/]*\/\/\([^@]*@\)\?\([^:/]*\).*/\2/"`
  if [[ ! " ${IPLIST[@]} " =~ " ${IP} " ]]; then
      echo "${NODEIDS[i]} ${URLS[i]} not found!"
      docker exec -it --env NODEID=${NODEIDS[i]} ${docker_spdm_id} sh -c 'sh $SPDM_HOME/spdm-main/bin/spdm_admin.sh --removeNode --nodeId $NODEID'
  fi
done
