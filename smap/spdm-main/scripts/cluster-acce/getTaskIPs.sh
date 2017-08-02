#!/bin/sh
#
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -r ${SCRIPT_DIR}/env.sh ] ; then
   . ${SCRIPT_DIR}/env.sh
fi
docker inspect -f "{{range .NetworksAttachments}}{{if eq .Network.Spec.Name \"${SWARM_NETWORK}\"}}{{index .Addresses 0}}{{end}}{{end}}" $(docker service ps -q spdmnode) |  cut -d "/" -f1
