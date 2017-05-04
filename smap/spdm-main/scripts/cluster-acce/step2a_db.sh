#!/bin/sh
#
# Script that create orable database tables
#
#alias docker="sudo docker"
docker_spdm_id=`docker ps | grep oodthub/spdm-services | awk '{print $1}'`
#
docker exec -it ${docker_spdm_id} sh -c 'cd /usr/local/spdm/build; sh setupSPDMDB.sh'
