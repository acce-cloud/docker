#!/bin/sh
alias docker="sudo docker"
# Script that submits the regression test
docker_spdm_id=`docker ps | grep oodthub/spdm-services | awk '{print $1}'`
#
# Perform regression steps according to 
# https://github.jpl.nasa.gov/SPDM/spdm/blob/master/spdm-main/src/test/bin/regression/README.txt
#
docker exec -it ${docker_spdm_id} sh -c 'cd $SPDM_HOME/spdm-main/bin; sh onDemand.sh -granule 2001-09-01 -auto'
echo "Waiting 3 minutes to complete L3 processing..."
sleep 180
