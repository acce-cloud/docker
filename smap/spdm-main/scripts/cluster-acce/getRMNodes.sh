#!/bin/sh
#
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -r ${SCRIPT_DIR}/env.sh ] ; then
   . ${SCRIPT_DIR}/env.sh
fi
docker_spdm_id=`docker ps | grep oodthub/spdm-services | awk '{print $1}'`
docker exec -it ${docker_spdm_id} sh -c 'sh $SPDM_HOME/spdm-main/bin/spdm_admin.sh --getNodes'
