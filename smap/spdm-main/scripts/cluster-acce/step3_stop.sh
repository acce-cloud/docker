#!/bin/sh
# Removes the swarm.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -r ${SCRIPT_DIR}/env.sh ] ; then
   . ${SCRIPT_DIR}/env.sh
fi
#
# stop services
#
docker service rm spdmserver spdmnode orcldb
rm ${SHARED_DIR}/workspace/pid/*.pid
sleep 5
docker service ls
docker ps -a
