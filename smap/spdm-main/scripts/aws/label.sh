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
for node in ${AVAILABLE_NODE_LIST} ; do
  docker node update --label-add acce_stub=false ${node}
  sleep 1
done
for node in ${NODE_LIST} ; do
  docker node update --label-add acce_stub=true ${node}
  sleep 1
done
