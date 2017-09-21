#!/bin/sh
#alias docker="sudo docker"
# Script that submits the regression test
docker_spdm_id=`docker ps | grep oodthub/spdm-services | awk '{print $1}'`
#
# Perform regression steps according to 
# https://github.jpl.nasa.gov/SPDM/spdm/blob/master/spdm-main/src/test/bin/regression/README.txt
#
docker exec -it ${docker_spdm_id} sh -c 'cp $SPDM_HOME/spdm-main/bin/test/testdata/regression/V205*VCD* /project/spdm/staging/edos/incoming/.'
echo "Waiting 5 minutes to finish L0-L2 processing..."
sleep 300
