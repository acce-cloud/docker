#!/bin/sh
#
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -r ${SCRIPT_DIR}/env.sh ] ; then
   . ${SCRIPT_DIR}/env.sh
fi
#
# Initializes the swarm, starts swarm visualizer tool.
#
docker swarm init --advertise-addr $MANAGER_IP
token_worker=`docker swarm join-token --quiet worker`

docker network create -d overlay ${SWARM_NETWORK}
sleep 2

for node in ${NODE_LIST} ; do
   echo "please ssh ${node} and type this command:"
   echo "docker swarm join --token $token_worker ${MANAGER_IP}:2377"
   read -p "Press any key to continue... "
#  ssh ${node} docker swarm join --token $token_worker $MANAGER_IP:2377
  sleep 1
done

docker network ls
docker node ls

#docker run -it -d -p 8080:8080 -e HOST=$MANAGER_IP -e PORT=8080 -v /var/run/docker.sock:/var/run/docker.sock --name visualizer manomarks/visualizer
