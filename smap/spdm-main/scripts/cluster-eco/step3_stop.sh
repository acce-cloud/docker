#!/bin/sh
# Removes the swarm.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -r ${SCRIPT_DIR}/env.sh ] ; then
   . ${SCRIPT_DIR}/env.sh
fi
#
# stop services
#
docker service rm spdmserver spdmnode 
docker service ls
