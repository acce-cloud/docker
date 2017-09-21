#!/bin/sh
# Removes the swarm.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -r ${SCRIPT_DIR}/env.sh ] ; then
   . ${SCRIPT_DIR}/env.sh
fi
#
# remove swarm will stop services too

for node in ${NODE_LIST} ; do
   echo "Please ssh ${node} and type this command:"
   echo "docker swarm leave"
   read -p "Press any key to continue... "
#   ssh ${node} docker swarm leave
done

docker swarm leave --force
docker network rm ${SWARM_NETWORK}

docker network ls
